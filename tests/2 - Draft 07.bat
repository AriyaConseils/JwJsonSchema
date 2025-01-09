@echo off

rem =========================================================
rem Creation de l'arborescence : test_3
rem =========================================================
if not exist test_3 (
    mkdir test_3
)
if not exist test_3\data_success (
    mkdir test_3\data_success
)
if not exist test_3\data_fail (
    mkdir test_3\data_fail
)

rem =========================================================
rem 1) Generation du fichier de schema principal : main.json
rem =========================================================
(
echo {
echo   "$schema": "http://json-schema.org/draft-07/schema#",
echo   "title": "Schéma principal avancé",
echo   "type": "object",

rem --- On reference un sous-schema externe sub_schema.json ---
echo   "properties": {
echo     "fullName": {
echo       "description": "Doit être une chaîne non vide",
echo       "$ref": "sub_schema.json#/definitions/nonEmptyString"
echo     },
echo     "address": {
echo       "$ref": "sub_schema.json#/definitions/addressObj"
echo     },

rem --- Exemples de proprietes additionnelles ---
echo     "favoriteColor": {
echo       "$ref": "#colorAnchor"
echo     },
echo     "preferredContact": {
echo       "oneOf": [
echo         { "type": "string", "format": "email" },
echo         { "type": "string", "pattern": "^\\+[1-9][0-9]{7,14}$" }
echo       ]
echo     },
echo     "tags": {
echo       "type": "array",
echo       "items": { "type": "string", "minLength": 1 },
echo       "uniqueItems": true
echo     },
echo     "metadata": {
echo       "$ref": "#/definitions/metadataSchema"
echo     },
echo     "forbiddenField": {
echo       "not": {}
echo     }
echo   },

rem --- On utilise un anchor local (ex: colorAnchor) ---
echo   "$anchor": "mainRoot",

rem --- $anchor supplementaire pour favoriteColor ---
echo   "$defs": {
echo     "colorDef": {
echo       "$anchor": "colorAnchor",
echo       "type": "string",
echo       "pattern": "^(#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6}))$",
echo       "description": "Une couleur hexadecimale (ex: #FFF ou #FFFFFF)."
echo     }
echo   },

rem --- definitions internes au main.json ---
echo   "definitions": {
echo     "metadataSchema": {
echo       "type": "object",
echo       "required": ["version"],
echo       "properties": {
echo         "version": {
echo           "type": "string",
echo           "pattern": "^v\\d+\\.\\d+$"
echo         },
echo         "author": {
echo           "type": "string"
echo         }
echo       },
echo       "additionalProperties": false
echo     }
echo   },

rem --- Proprietes globales ---
echo   "required": ["fullName", "address"],
echo   "additionalProperties": false
echo }
) > test_3\main.json

rem =========================================================
rem 2) Generation du sous-schema sub_schema.json
rem =========================================================
(
echo {
echo   "$schema": "http://json-schema.org/draft-07/schema#",
echo   "title": "Sous-schema reference par main.json",

rem --- On definit des definitions re-utilisables ---
echo   "definitions": {
echo     "nonEmptyString": {
echo       "type": "string",
echo       "minLength": 1
echo     },
echo     "addressObj": {
echo       "$anchor": "addressAnchor",
echo       "type": "object",
echo       "required": ["city", "zipcode"],
echo       "properties": {
echo         "city": {
echo           "type": "string",
echo           "minLength": 2
echo         },
echo         "zipcode": {
echo           "type": "string",
echo           "pattern": "^[0-9]{5}$"
echo         },
echo         "country": {
echo           "type": "string",
echo           "default": "France"
echo         }
echo       },
echo       "additionalProperties": false
echo     }
echo   }
echo }
) > test_3\sub_schema.json

rem =========================================================
rem 3) FICHIERS QUI DOIVENT REUSSIR => data_success
rem =========================================================

rem A) Instance valide, tout references OK
(
echo {
echo   "fullName": "Alice Wonderland",
echo   "address": {
echo     "city": "Paris",
echo     "zipcode": "75001"
echo   },
echo   "favoriteColor": "#FFAA00",
echo   "preferredContact": "alice@example.com",
echo   "tags": ["dev", "draft7"],
echo   "metadata": {
echo     "version": "v1.0",
echo     "author": "Alice"
echo   }
echo }
) > test_3\data_success\A_valid.json

rem B) Instance valide: contact en telephone + metadata + country
(
echo {
echo   "fullName": "Bob the builder",
echo   "address": {
echo     "city": "NY",
echo     "zipcode": "12345",
echo     "country": "USA"
echo   },
echo   "favoriteColor": "#FFF",
echo   "preferredContact": "+33123456789",
echo   "tags": ["tag1", "tag2"],
echo   "metadata": {
echo     "version": "v2.1"
echo   }
echo }
) > test_3\data_success\B_valid.json

rem C) On n'a pas mis 'favoriteColor' ni 'preferredContact' => pas required => OK
(
echo {
echo   "fullName": "Charlie Chaplin",
echo   "address": {
echo     "city": "LA",
echo     "zipcode": "90001"
echo   },
echo   "tags": [],
echo   "metadata": {
echo     "version": "v3.0"
echo   }
echo }
) > test_3\data_success\C_noOptionalFields.json


rem =========================================================
rem 4) FICHIERS QUI DOIVENT ECHOUER => data_fail
rem =========================================================

rem D) "fullName" vide => minLength=1 => FAIL
(
echo {
echo   "fullName": "",
echo   "address": {
echo     "city": "Paris",
echo     "zipcode": "75001"
echo   }
echo }
) > test_3\data_fail\D_emptyFullName.json

rem E) address.zipcode non conforme => pattern ^[0-9]{5}$ => FAIL
(
echo {
echo   "fullName": "Eddy",
echo   "address": {
echo     "city": "Paris",
echo     "zipcode": "12AB5"
echo   },
echo   "favoriteColor": "#FFFFFF"
echo }
) > test_3\data_fail\E_badZipcode.json

rem F) forbiddenField => "not": {} => FAIL
(
echo {
echo   "fullName": "Frank",
echo   "address": {
echo     "city": "Paris",
echo     "zipcode": "75001"
echo   },
echo   "forbiddenField": true
echo }
) > test_3\data_fail\F_forbiddenField.json

rem G) additionalProperties=false => on ajoute un champ "extra" non defini => FAIL
(
echo {
echo   "fullName": "George",
echo   "address": {
echo     "city": "Marseille",
echo     "zipcode": "13001"
echo   },
echo   "extra": "Je suis en trop"
echo }
) > test_3\data_fail\G_extraProperty.json

rem H) favoriteColor ne respecte pas le pattern #RGB ou #RRGGBB => FAIL
(
echo {
echo   "fullName": "Hector",
echo   "address": {
echo     "city": "Lyon",
echo     "zipcode": "69001"
echo   },
echo   "favoriteColor": "NotAColor",
echo   "metadata": {
echo     "version": "v1.0"
echo   }
echo }
) > test_3\data_fail\H_badColorPattern.json

rem I) metadata => version ne match pas pattern ^v\\d+\\.\\d+$
(
echo {
echo   "fullName": "Isaac",
echo   "address": {
echo     "city": "Nantes",
echo     "zipcode": "44000"
echo   },
echo   "metadata": {
echo     "version": "version1.0"
echo   }
echo }
) > test_3\data_fail\I_badMetadataVersion.json

rem J) "preferredContact": ni email ni phone => FAIL
(
echo {
echo   "fullName": "Jack",
echo   "address": {
echo     "city": "Paris",
echo     "zipcode": "75001"
echo   },
echo   "preferredContact": "JustAString", 
echo   "metadata": {
echo     "version": "v1.2"
echo   }
echo }
) > test_3\data_fail\J_invalidPreferredContact.json

rem K) someArray => type=string => on met un nombre => FAIL
(
echo {
echo   "fullName": "Karl",
echo   "address": {
echo     "city": "Toulouse",
echo     "zipcode": "31000"
echo   },
echo   "someArray": ["hello", 123],
echo   "metadata": {
echo     "version": "v2.0"
echo   }
echo }
) > test_3\data_fail\K_invalidArrayItem.json

echo.
echo [OK] Les schemas (main.json, sub_schema.json) et fichiers de test ont ete crees dans ^"test_3^".
pause
