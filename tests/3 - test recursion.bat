@echo off

rem ================================================
rem Création des répertoires pour le test
rem ================================================
if not exist test_4 (
    mkdir test_4
)
if not exist test_4\data_success (
    mkdir test_4\data_success
)
if not exist test_4\data_fail (
    mkdir test_4\data_fail
)

rem ================================================
rem Génération du schéma avec récursion
rem ================================================
(
echo {
echo   "$schema": "http://json-schema.org/draft-07/schema#",
echo   "type": "object",
echo   "properties": {
echo     "age": { "type": "integer" },
echo     "children": {
echo       "type": "array",
echo       "items": { "$ref": "#" }
echo     }
echo   },
echo   "required": ["age"],
echo   "additionalProperties": {
echo     "$ref": "#"
echo   }
echo }
) > test_4\main.json

rem ================================================
rem Données de test
rem ================================================

rem Fichier JSON valide (toutes les clés "age" sont des entiers)
(
echo {
echo   "name": "Valid User",
echo   "age": 40,
echo   "profile": {
echo     "age": 25,
echo     "details": {
echo       "age": 30
echo     }
echo   },
echo   "children": [
echo     {
echo       "name": "Child 1",
echo       "age": 10,
echo       "details": {
echo         "age": 5
echo       }
echo     },
echo     {
echo       "name": "Child 2",
echo       "age": 15
echo     }
echo   ]
echo }
) > test_4\data_success\valid.json

rem Fichier JSON invalide (une clé "age" n'est pas un entier)
(
echo {
echo   "name": "Invalid User",
echo   "age": "not an integer",
echo   "profile": {
echo     "age": 25,
echo     "details": {
echo       "age": true
echo     }
echo   },
echo   "children": [
echo     {
echo       "name": "Child 1",
echo       "age": "invalid"
echo     }
echo   ]
echo }
) > test_4\data_fail\invalid.json

rem Fichier JSON invalide (clé "age" manquante dans un sous-objet)
(
echo {
echo   "name": "Missing Age User",
echo   "profile": {
echo     "details": {}
echo   },
echo   "children": [
echo     {
echo       "name": "Child 1"
echo     }
echo   ]
echo }
) > test_4\data_fail\missing_age.json

echo.
echo [OK] Le schéma récursif et les fichiers de test ont été créés dans le dossier "test_4".
pause
