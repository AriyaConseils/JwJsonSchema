@echo off

rem === Création de l'arborescence "test_2" ===
if not exist test_2 (
    mkdir test_2
)
if not exist test_2\data_success (
    mkdir test_2\data_success
)
if not exist test_2\data_fail (
    mkdir test_2\data_fail
)


rem ================================================
rem Génération du schéma
rem ================================================
(
echo {
echo   ^"$schema^": ^"https://json-schema.org/draft/2020-12/schema^",
echo   ^"$id^": ^"schema^",
echo   ^"$defs^": {
echo     ^"Address^": {
echo       ^"$anchor^": ^"addressDef^",
echo       ^"type^": ^"object^",
echo       ^"required^": [^"city^"],
echo       ^"properties^": {
echo         ^"city^": {
echo           ^"type^": ^"string^",
echo           ^"minLength^": 2
echo         },
echo         ^"zipcode^": {
echo           ^"type^": ^"string^",
echo           ^"pattern^": ^"^[0-9]{5}^"
echo         }
echo       }
echo     },
echo     ^"PositiveNumber^": {
echo       ^"type^": ^"number^",
echo       ^"exclusiveMinimum^": 0
echo     }
echo   },
echo   ^"type^": ^"object^",
echo   ^"properties^": {
echo     ^"name^": {
echo       ^"type^": ^"string^",
echo       ^"minLength^": 1
echo     },
echo     ^"age^": {
echo       ^"$ref^": ^"#/$defs/PositiveNumber^"
echo     },
echo     ^"address^": {
echo       ^"$ref^": ^"#/$defs/Address^"
echo     },
echo     ^"billingAddress^": {
echo       ^"$ref^": ^"#addressDef^"
echo     },
echo     ^"role^": {
echo       ^"enum^": [^"user^", ^"admin^"]
echo     },
echo     ^"forbiddenField^": {
echo       ^"type^": ^"boolean^"
echo     }
echo   },
echo   ^"not^": {
echo     ^"required^": [^"forbiddenField^"]
echo   },
echo   ^"allOf^": [
echo     {
echo       ^"required^": [^"name^"]
echo     }
echo   ]
echo }
) > "test_2\main.json"


rem ------------------------------------------------
rem A) Instance valide: name + age + address + billingAddress + role=user
rem expected = true
rem ------------------------------------------------
(
echo {
echo   "name": "Alice",
echo   "age": 25,
echo   "address": {
echo     "city": "Paris",
echo     "zipcode": "75000"
echo   },
echo   "billingAddress": {
echo     "city": "Lyon"
echo   },
echo   "role": "user"
echo }
) > test_2\data_success\A_valid.json

rem ------------------------------------------------
rem B) Echec: forbiddenField présent => 'not' viole
rem expected = false
rem ------------------------------------------------
(
echo {
echo   "name": "Bob",
echo   "age": 30,
echo   "forbiddenField": false,
echo   "address": {
echo     "city": "NY"
echo   }
echo }
) > test_2\data_fail\B_forbiddenField.json

rem ------------------------------------------------
rem C) Echec: name manquant => allOf => required
rem expected = false
rem ------------------------------------------------
(
echo {
echo   "age": 10,
echo   "address": { "city": "Tokyo" }
echo }
) > test_2\data_fail\C_missingName.json

rem ------------------------------------------------
rem D) Echec: age= -5 => PositiveNumber => exclusiveMinimum=0
rem expected = false
rem ------------------------------------------------
(
echo {
echo   "name": "Danny",
echo   "age": -5,
echo   "address": { "city": "Oslo" }
echo }
) > test_2\data_fail\D_negativeAge.json

rem ------------------------------------------------
rem E) Echec: address => city="A" => minLength=2
rem expected = false
rem ------------------------------------------------
(
echo {
echo   "name": "Eva",
echo   "age": 20,
echo   "address": {
echo     "city": "A"
echo   }
echo }
) > test_2\data_fail\E_cityTooShort.json

rem ------------------------------------------------
rem F) Echec: billingAddress => zipcode="1234" => pattern=^[0-9]{5}$
rem expected = false
rem ------------------------------------------------
(
echo {
echo   "name": "Fred",
echo   "age": 40,
echo   "address": {
echo     "city": "CityName"
echo   },
echo   "billingAddress": {
echo     "city": "OtherCity",
echo     "zipcode": "1234"
echo   }
echo }
) > test_2\data_fail\F_zipcodePatternFail.json

rem ------------------------------------------------
rem G) OK: billingAddress sans zipcode, address complet => role=admin
rem expected = true
rem ------------------------------------------------
(
echo {
echo   "name": "George",
echo   "age": 18,
echo   "address": {
echo     "city": "Metropolis",
echo     "zipcode": "12345"
echo   },
echo   "billingAddress": {
echo     "city": "Gotham"
echo   },
echo   "role": "admin"
echo }
) > test_2\data_success\G_valid.json

rem ------------------------------------------------
rem H) Echec: role en dehors de l'enum => 'super-admin'
rem expected = false
rem ------------------------------------------------
(
echo {
echo   "name": "Hugo",
echo   "age": 35,
echo   "address": {
echo     "city": "Paris"
echo   },
echo   "billingAddress": {
echo     "city": "Paris"
echo   },
echo   "role": "super-admin"
echo }
) > test_2\data_fail\H_invalidRole.json

rem ------------------------------------------------
rem I) Ni 'address' ni 'billingAddress' => 
rem => On a choisi expected = true (car dans le code, c'est mis "true")
rem ------------------------------------------------
(
echo {
echo   "name": "Isaac",
echo   "age": 12
echo }
) > test_2\data_success\I_valid.json

rem ------------------------------------------------
rem J) Echec: city manquant dans address => required: [city]
rem expected = false
rem ------------------------------------------------
(
echo {
echo   "name": "Jack",
echo   "age": 18,
echo   "address": {
echo     "zipcode": "12345"
echo   }
echo }
) > test_2\data_fail\J_missingCity.json

echo.
echo [OK] Les répertoires et fichiers de test ont été créés dans ^"test_2^".
pause
