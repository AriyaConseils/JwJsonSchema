#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStringList>

#include "SwJsonSchema.h"

//--------------------------------------------------------------------
// Représente le résultat d'un seul fichier de test
//--------------------------------------------------------------------
struct ValidationResult
{
    QString testDirName;   // Nom du sous-répertoire de test (ex: "test_1")
    QString dataFileName;  // Nom du fichier de données (ex: "validA.json")
    bool    success;       // True si le test est considéré comme OK
    QString error;         // Message d'erreur si échec
};

//--------------------------------------------------------------------
// Fonction utilitaire pour charger un QJsonDocument à partir d'un fichier
//--------------------------------------------------------------------
QJsonDocument loadJsonDocument(const QString &filePath, bool *ok = nullptr, QString *errorString = nullptr)
{
    if (ok) {
        *ok = false;
    }

    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        if (errorString) {
            *errorString = QString("Impossible d'ouvrir le fichier : %1").arg(filePath);
        }
        return QJsonDocument();
    }

    QByteArray jsonData = file.readAll();
    file.close();

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(jsonData, &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        if (errorString) {
            *errorString = QString("Erreur de parsing JSON : %1").arg(parseError.errorString());
        }
        return QJsonDocument();
    }

    if (ok) {
        *ok = true;
    }
    return doc;
}

//--------------------------------------------------------------------
// Sous-fonction pour valider un répertoire
//   ex : data_success/ => expectedToPass = true
//        data_fail/    => expectedToPass = false
//--------------------------------------------------------------------
static QList<ValidationResult> validateDataDirectory(
    const SwJsonSchema &schema,
    const QString       &testDirName,
    const QString       &dataDirPath,
    bool                expectedToPass)
{
    QList<ValidationResult> results;

    QDir dataDir(dataDirPath);
    if (!dataDir.exists()) {
        // Pas de répertoire => pas de tests
        return results;
    }

    // Filtrer uniquement les fichiers *.json
    QStringList dataFiles = dataDir.entryList(QStringList() << "*.json", QDir::Files | QDir::NoSymLinks);
    for (const QString &dataFile : dataFiles) {
        QString dataFilePath = dataDir.absoluteFilePath(dataFile);

        bool dataOk = false;
        QString dataParseError;
        QJsonDocument dataDoc = loadJsonDocument(dataFilePath, &dataOk, &dataParseError);

        ValidationResult result;
        result.testDirName  = testDirName;  // ex: "test_1"
        result.dataFileName = dataFile;     // ex: "validA.json"
        result.success      = true;         // on suppose "true", on ajustera ensuite

        if (!dataOk) {
            // Echec de chargement du JSON
            result.success = false;
            result.error   = dataParseError;
            results << result;
            continue;
        }

        // Valider l'objet JSON
        QString errorMsg;
        bool actualValidation = schema.validate(dataDoc.object(), &errorMsg);

        // On compare le résultat réel (actualValidation) à l'attendu (expectedToPass)
        if (actualValidation != expectedToPass) {
            // Echec si ça ne match pas l'attendu
            result.success = false;
            if (actualValidation) {
                // On a validé un JSON qu'on s'attendait à voir échouer
                result.error = QString("Le JSON '%1' est validé alors qu'il devait échouer.")
                                   .arg(dataFile);
            } else {
                // On a rejeté un JSON qu'on s'attendait à voir réussir
                result.error = QString("Le JSON '%1' est rejeté alors qu'il devait réussir. Erreur: %2")
                                   .arg(dataFile)
                                   .arg(errorMsg.isEmpty() ? "(non spécifiée)" : errorMsg);
            }
        }

        results << result;
    }

    return results;
}

//--------------------------------------------------------------------
// Fonction pour traiter un répertoire de test :
//    1) Charger le schéma "main.json"
//    2) Parcourir data_success/ et data_fail/
//--------------------------------------------------------------------
static QList<ValidationResult> runTestDirectory(const QString &testDirPath)
{
    QList<ValidationResult> results;

    // 1) Charger le schéma principal via SwJsonSchema
    QString schemaFilePath = QDir(testDirPath).absoluteFilePath("main.json");
    SwJsonSchema schema(schemaFilePath);
    if (!schema.isValide()) {
        // Impossible de charger le schéma => On marque l'échec global
        ValidationResult r;
        r.testDirName  = QFileInfo(testDirPath).fileName();
        r.dataFileName = "main.json";
        r.success      = false;
        r.error        = "Echec de l'initialisation du schéma (isValide() == false).";
        results << r;
        return results;
    }

    // 2a) Valider tous les fichiers dans data_success (expectedToPass = true)
    QString testDirName = QFileInfo(testDirPath).fileName(); // ex: "test_1"
    QString dataSuccessDirPath = QDir(testDirPath).absoluteFilePath("data_success");
    results.append( validateDataDirectory(schema, testDirName, dataSuccessDirPath, true) );

    // 2b) Valider tous les fichiers dans data_fail (expectedToPass = false)
    QString dataFailDirPath = QDir(testDirPath).absoluteFilePath("data_fail");
    results.append( validateDataDirectory(schema, testDirName, dataFailDirPath, false) );

    return results;
}

//--------------------------------------------------------------------
// Fonction pour afficher un rapport d'erreur détaillé
//--------------------------------------------------------------------
static void reportFailures(const QList<ValidationResult> &allResults)
{
    int passCount = 0;
    int failCount = 0;

    // Affiche un détail ligne par ligne
    for (const ValidationResult &r : allResults) {
        if (r.success) {
            passCount++;
        } else {
            failCount++;
            qDebug().noquote()
                << QString("[FAIL] - TestDir: '%1' | DataFile: '%2' | Erreur: %3")
                       .arg(r.testDirName)
                       .arg(r.dataFileName)
                       .arg(r.error.isEmpty() ? "(non spécifiée)" : r.error);
        }
    }

    // Récap global
    qDebug().noquote() << "\n----- Récapitulatif global -----";
    qDebug().noquote() << "Tests réussis :" << passCount;
    qDebug().noquote() << "Tests échoués :" << failCount;
    qDebug().noquote() << "--------------------------------\n";
}

//--------------------------------------------------------------------
// Programme principal
//--------------------------------------------------------------------
int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    SwJsonSchema::registerCustomKeyword("dividedBy", [](const QJsonValue& rules, const QJsonValue& data, QString* error) -> bool {
        qWarning() << "Le répertoire de tests n'existe pas :" << rules << data;
        if(!data.isDouble()){
            *error = "Value is not a number";
            return false;
        }
        if(!rules.isObject() || !rules.toObject().contains("operator")){
            *error = "Schema is wrong: shall contain \"dividedBy\":{\"operator\": number}";
            return false;
        }
        int multiple = rules.toObject()["operator"].toInt();
        double value = data.toDouble();

        if (multiple != 0 && std::fmod(value, multiple) == 0) {
            return true;
        }
        *error = QString("value %1 is not a multiple of %2").arg(value).arg(multiple);
        return false;
    });

    // Si vous voulez prendre un argument (ex: chemin "tests/"),
    // vous pouvez le récupérer dans argv[1], sinon on met un chemin par défaut.
    QString testsRoot = (argc > 1) ? QString::fromUtf8(argv[1]) : "tests";
    QDir rootDir(testsRoot);

    if (!rootDir.exists()) {
        qWarning() << "Le répertoire de tests n'existe pas :" << testsRoot;
        return -1;
    }

    // Lister tous les sous-répertoires (chaque sous-répertoire = un test)
    QStringList testDirs = rootDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);

    QList<ValidationResult> allResults;
    for (const QString &subDir : testDirs) {
        QString testDirPath = rootDir.absoluteFilePath(subDir);
        QList<ValidationResult> results = runTestDirectory(testDirPath);
        allResults.append(results);
    }

    // Générer un rapport global
    reportFailures(allResults);

    return 0;
}
