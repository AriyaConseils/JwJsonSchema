@echo off

rem ================================================
rem Création de l'arborescence de test
rem ================================================
if not exist test_1 (
    mkdir test_1
)
if not exist test_1\data_success (
    mkdir test_1\data_success
)
if not exist test_1\data_fail (
    mkdir test_1\data_fail
)
rem ================================================
rem Génération du schéma
rem ================================================
(
echo {
echo   "type": "object",
echo   "required": ["name", "age"],
echo   "properties": {
echo     "name": {
echo       "type": "string",
echo       "minLength": 2,
echo       "maxLength": 30,
echo       "pattern": "^[A-Za-z]+$"
echo     },
echo     "childSpecificField": {
echo       "type": "string",
echo       "minLength": 2,
echo       "maxLength": 30
echo     },
echo     "age": {
echo       "type": "number",
echo       "minimum": 0,
echo       "maximum": 150,
echo       "exclusiveMinimum": false,
echo       "exclusiveMaximum": true
echo     },
echo     "favNumber": {
echo       "type": "number",
echo       "multipleOf": 2
echo     },
echo     "gender": {
echo       "enum": ["male", "female", "other"]
echo     },
echo     "constValue": {
echo       "const": true
echo     },
echo     "tags": {
echo       "type": "array",
echo       "minItems": 1,
echo       "maxItems": 5,
echo       "uniqueItems": true,
echo       "items": {
echo         "type": "string"
echo       }
echo     },
echo     "emails": {
echo       "type": "array",
echo       "contains": {
echo         "format": "email"
echo       },
echo       "minContains": 1,
echo       "maxContains": 2
echo     },
echo     "profile": {
echo       "type": "object",
echo       "required": ["bio"],
echo       "properties": {
echo         "bio": {
echo           "type": "string"
echo         }
echo       },
echo       "patternProperties": {
echo         "^secret_": {
echo           "type": "boolean"
echo         }
echo       },
echo       "additionalProperties": false
echo     },
echo     "adultSpecificField": {
echo       "type": "string"
echo     },
echo     "anyOfTest": {
echo       "description": "test pour anyOf"
echo     },
echo     "oneOfTest": {
echo       "description": "test pour oneOf"
echo     },
echo     "forbidden": {
echo       "description": "champ interdit"
echo     }
echo   },
echo   "patternProperties": {
echo     "^extra_": {
echo       "type": "string"
echo     }
echo   },
echo   "additionalProperties": false,
echo   "dependentRequired": {
echo     "name": ["gender"]
echo   },
echo   "allOf": [
echo     {
echo       "type": "object"
echo     }
echo   ],
echo   "anyOf": [
echo     {
echo       "properties": {
echo         "anyOfTest": {
echo           "type": "number"
echo         }
echo       }
echo     },
echo     {
echo       "properties": {
echo         "anyOfTest": {
echo           "type": "string"
echo         }
echo       }
echo     }
echo   ],
echo   "if": {
echo     "properties": {
echo       "age": { "maximum": 12 }
echo     }
echo   },
echo   "then": {
echo     "required": ["childSpecificField"]
echo   },
echo   "else": {
echo     "required": ["adultSpecificField"]
echo   },
echo   "oneOf": [
echo     {
echo       "properties": {
echo         "oneOfTest": {
echo           "type": "number"
echo         }
echo       },
echo       "required": ["oneOfTest"]
echo     },
echo     {
echo       "properties": {
echo         "oneOfTest": {
echo           "type": "string"
echo         }
echo       },
echo       "required": ["oneOfTest"]
echo     }
echo   ],
echo   "not": {
echo     "required": ["forbidden"]
echo   }
echo }
) > "test_1\main.json"


rem ================================================
rem FICHIERS "data_success"
rem ================================================

rem A) Instance complète et valide (enfant)
(
echo {
echo   "name": "Alice",
echo   "age": 10,
echo   "favNumber": 4,
echo   "gender": "female",
echo   "constValue": true,
echo   "tags": ["music", "coding"],
echo   "emails": ["alice@example.com", "bob@somewhere.net"],
echo   "profile": {
echo     "bio": "Je suis une fan de code.",
echo     "secret_token": false
echo   },
echo   "extra_info": "du texte",
echo   "childSpecificField": "jouets",
echo   "oneOfTest": 30
echo }
) > test_1\data_success\A_validInstance.json

rem G) Instance "name" => "gender" => OK (dépendance respectée)
(
echo {
echo   "name": "Frank",
echo   "gender": "male",
echo   "age": 20,
echo   "constValue": true,
echo   "tags": ["tag1"],
echo   "emails": ["frank@example.org"],
echo   "profile": { "bio": "OK" },
echo   "adultSpecificField": "some data",
echo   "oneOfTest": "test String"
echo }
) > test_1\data_success\G_missingDependentField.json

rem I) anyOf => "anyOfTest" = number => OK
(
echo {
echo   "name": "Henry",
echo   "gender": "male",
echo   "age": 50,
echo   "constValue": true,
echo   "tags": ["something"],
echo   "emails": ["henry@example.org"],
echo   "profile": { "bio": "OK" },
echo   "adultSpecificField": "some data",
echo   "oneOfTest": "test String",
echo   "anyOfTest": 123
echo }
) > test_1\data_success\I_anyOfNumber.json

rem J) anyOf => "anyOfTest" = string => OK
(
echo {
echo   "name": "Iris",
echo   "gender": "female",
echo   "age": 50,
echo   "constValue": true,
echo   "tags": ["something"],
echo   "emails": ["iris@example.org"],
echo   "profile": { "bio": "OK" },
echo   "adultSpecificField": "some data",
echo   "oneOfTest": "test String",
echo   "anyOfTest": "texte"
echo }
) > test_1\data_success\J_anyOfString.json

rem L) oneOf => "oneOfTest" = 2 => match sur le 1er
(
echo {
echo   "name": "Kevin",
echo   "gender": "male",
echo   "age": 50,
echo   "constValue": true,
echo   "tags": ["something"],
echo   "emails": ["kevin@example.org"],
echo   "profile": { "bio": "OK" },
echo   "adultSpecificField": "some data",
echo   "oneOfTest": 2
echo }
) > test_1\data_success\L_oneOfNumberOK.json

rem M) oneOf => "oneOfTest" = "deux" => match sur le 2e
(
echo {
echo   "name": "Leo",
echo   "gender": "male",
echo   "age": 50,
echo   "constValue": true,
echo   "tags": ["something"],
echo   "emails": ["leo@example.org"],
echo   "profile": { "bio": "OK" },
echo   "adultSpecificField": "some data",
echo   "oneOfTest": "deux"
echo }
) > test_1\data_success\M_oneOfStringOK.json

rem ================================================
rem FICHIERS "data_fail"
rem ================================================

rem B) Instance manquant "name" => required => FAIL
(
echo {
echo   "age": 20
echo }
) > test_1\data_fail\B_missingRequired.json

rem C) "name" = "A" => trop court => FAIL
(
echo {
echo   "name": "A",
echo   "gender": "male",
echo   "age": 30,
echo   "adultSpecificField": "voiture",
echo   "oneOfTest": "test String"
echo }
) > test_1\data_fail\C_invalidStringLength.json

rem D) "favNumber" = 3 => multipleOf=2 => FAIL
(
echo {
echo   "name": "Bob",
echo   "gender": "male",
echo   "age": 30,
echo   "favNumber": 3,
echo   "constValue": true,
echo   "tags": ["tag1"],
echo   "emails": ["bob@example.org"],
echo   "profile": { "bio": "OK" },
echo   "adultSpecificField": "licence",
echo   "oneOfTest": "test String"
echo }
) > test_1\data_fail\D_invalidMultipleOf.json

rem E) exclusiveMaximum => "age" = 150 => FAIL
(
echo {
echo   "name": "Carol",
echo   "gender": "female",
echo   "age": 150,
echo   "constValue": true,
echo   "tags": ["tag1"],
echo   "emails": ["carol@example.org"],
echo   "profile": { "bio": "OK" },
echo   "adultSpecificField": "quelque chose",
echo   "oneOfTest": "test String"
echo }
) > test_1\data_fail\E_invalidExclusiveMax.json

rem F) "forbidden" => doit échouer sur "not"
(
echo {
echo   "name": "Eve",
echo   "gender": "female",
echo   "age": 10,
echo   "forbidden": true,
echo   "constValue": true,
echo   "tags": ["tag1"],
echo   "emails": ["eve@example.org"],
echo   "profile": { "bio": "OK" },
echo   "childSpecificField": "some data",
echo   "oneOfTest": "test String"
echo }
) > test_1\data_fail\F_hasForbiddenField.json

rem H) additionalProperties=false => "surprise" => FAIL
(
echo {
echo   "name": "Gina",
echo   "gender": "female",
echo   "age": 20,
echo   "constValue": true,
echo   "favNumber": 8,
echo   "tags": ["tag1"],
echo   "emails": ["gina@example.org"],
echo   "profile": { "bio": "OK" },
echo   "adultSpecificField": "some data",
echo   "oneOfTest": "test String",
echo   "surprise": "??? ..."
echo }
) > test_1\data_fail\H_additionalProp.json

rem K) anyOf => "anyOfTest"=true => ni string ni number => FAIL
(
echo {
echo   "name": "Jack",
echo   "gender": "male",
echo   "age": 50,
echo   "constValue": true,
echo   "tags": ["something"],
echo   "emails": ["jack@example.org"],
echo   "profile": { "bio": "OK" },
echo   "adultSpecificField": "some data",
echo   "oneOfTest": "test String",
echo   "anyOfTest": true
echo }
) > test_1\data_fail\K_invalidAnyOf.json

rem N) oneOf => "oneOfTest"=false => aucun match => FAIL
(
echo {
echo   "name": "Marie",
echo   "gender": "female",
echo   "age": 50,
echo   "constValue": true,
echo   "tags": ["something"],
echo   "emails": ["marie@example.org"],
echo   "profile": { "bio": "OK" },
echo   "adultSpecificField": "some data",
echo   "oneOfTest": false
echo }
) > test_1\data_fail\N_oneOfNoMatch.json

rem O) "contains" => liste "emails" n'a pas d'email "valide" => FAIL
(
echo {
echo   "name": "Nina",
echo   "gender": "female",
echo   "age": 15,
echo   "constValue": true,
echo   "tags": ["t1"],
echo   "emails": ["pasun@email.com","bla"],
echo   "profile": { "bio": "OK" },
echo   "childSpecificField": "some data",
echo   "oneOfTest": "test String"
echo }
) > test_1\data_fail\O_invalidContains.json

echo.
echo [OK] Les répertoires et fichiers de test ont été créés dans ^"test_1^".
pause
