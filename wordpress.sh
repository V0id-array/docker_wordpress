#!/bin/bash

# Preguntar al usuario si quiere usar valores de prueba
read -p "¿Desea usar valores de prueba para todas las variables? (¡Muy inseguro!) (s/n): " USE_TEST_VALUES

if [[ "$USE_TEST_VALUES" == "s" || "$USE_TEST_VALUES" == "S" ]]; then
    # Asignar valores de prueba
    DB_USER="test_user"
    DB_PASSWORD="test"
    ROOT_PASSWORD="test_root_password"
else
    # Solicitar las credenciales al usuario
    read -p "Ingrese el nombre de usuario de la base de datos: " DB_USER
    read -sp "Ingrese la contraseña de la base de datos: " DB_PASSWORD
    echo
    read -sp "Ingrese la contraseña de root para MySQL: " ROOT_PASSWORD
    echo
fi

# Exportar las variables para que Docker Compose pueda usarlas
export DB_USER
export DB_PASSWORD
export ROOT_PASSWORD

# Ejecutar archivo de Docker compose
docker-compose up -d 

