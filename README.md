# docker_wordpress

Se ha creado un despliegue de wordpress con docker compose para ello se ha usado un archivo docker-compose.yml con la siguiente configuración:

```yaml
version: '3'
services:
  wordpress:
    restart: on-failure
    image: wordpress:latest
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: ${DB_USER}
      WORDPRESS_DB_PASSWORD: ${DB_PASSWORD}
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wordpress_data:/var/www/html
    depends_on:
      - db
  db:
    image: mysql:5.7
    restart: on-failure
    environment:
      MYSQL_ROOT_PASSWORD: ${ROOT_PASSWORD}
      MYSQL_DATABASE: wordpress
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
volumes:
  wordpress_data:
  db_data:
```

## **Version**

- **`version: '3'`**: Especifica la versión del formato de archivo de Docker Compose que se está utilizando.

## **Servicios**

Los servicios definidos en este archivo son `wordpress` y `db`

1. **Servicio WordPress**
    - **`restart: on-failure`**: Reinicia el contenedor si falla.
    - **`image: wordpress:latest`**: Utiliza la imagen más reciente de WordPress disponible en Docker Hub.
    - **`ports`**:
        - **`"80:80"`**: Mapea el puerto 80 del contenedor al puerto 80 del host, permitiendo el acceso a WordPress a través del navegador. Si se llegase a desplegar esta página en un entorno de producción es recomendable usar el 443 para  usar certificados TLS
    - **`environment`**:
        - **`WORDPRESS_DB_HOST`**: Especifica el host de la base de datos, que en este caso es `db`.
        - **`WORDPRESS_DB_USER`, `WORDPRESS_DB_PASSWORD`, `WORDPRESS_DB_NAME`**: Variables de entorno que se utilizan para configurar la conexión a la
        base de datos.
    - **`volumes`**:
        - **`wordpress_data:/var/www/html`**: Monta un volumen persistente para almacenar los archivos de WordPress, asegurando que los datos no se pierdan cuando el contenedor se detiene o se elimina.
    - **`depends_on`**:
        - **`db`**:
        Indica que el servicio de WordPress depende del servicio de base de
        datos y garantiza que este último esté disponible antes de iniciar
        WordPress.
2. **Servicio MySQL**
    - **`image: mysql:5.7`**: Utiliza la imagen MySQL versión 5.7.
    - **`restart: on-failure`**: Reinicia el contenedor si falla.
    - **`environment`**:
        - **`MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`**: Configura las credenciales y la base de datos inicial para MySQL,
        utilizando también variables de entorno que deben ser definidas en un
        archivo `.env`.
        - Por seguridad no se han añadido los credenciales de la base de datos, para introducir estos datos se ha creado un script donde se pide por pantalla al administrador introducirlos manualmente.
    - **`volumes`**:
        - **`db_data:/var/lib/mysql`**: Monta un volumen persistente para almacenar los datos de la base de datos, garantizando su persistencia.

  ## Alternativa 
    
  Como alternativa en ambos contenedores se pueden cargar las variables de entorno con un fichero .env
    
  Ejemplo con la base de datos:
    
    ```
    db:
        image: mysql:5.7
        env_file:
          - var.env
    ```
    

He decidido usar un script en bash para cargar las credenciales ya creo que es más seguro gestionar estos credenciales con un gestor de contraseñas e introducirlos manualmente. 

## **Volúmenes**

- Los volúmenes `wordpress_data` y `db_data` son definidos al final del archivo, proporcionando almacenamiento persistente para los datos de WordPress y MySQL respectivamente.

# Script creado:

El script comienza preguntando al usuario si desea utilizar valores 
predeterminados (de prueba) para las variables relacionadas con la base 
de datos. Esto es útil para entornos de desarrollo, pero se advierte que es muy inseguro.

Sino se empieza a preguntar al usuario los credenciales que quiere configurar en el servidor para luego exportarlos con `export` ser leídos al ejecutar docker compose. 

Por ultimo ejecuta **docker compose** para levantar el archivo `docker-compose.yml`

```bash
#!/bin/bash

# Preguntar al usuario si quiere usar valores de prueba.
read -p "¿Desea usar valores de prueba para todas las variables? (¡Muy inseguro!) (s/n): " USE_TEST_VALUES

# Verificar la respuesta del usuario.
if [[ "$USE_TEST_VALUES" == "s" || "$USE_TEST_VALUES" == "S" ]]; then
    # Si el usuario opta por usar valores de prueba, asignar valores predeterminados a las variables.
    DB_USER="test_user"  
    DB_PASSWORD="test_password"  
    ROOT_PASSWORD="test_root_password"  
else
    # Si el usuario no quiere usar valores de prueba, solicitar las credenciales manualmente.
    read -p "Ingrese el nombre de usuario de la base de datos: " DB_USER  # Solicitar nombre de usuario.
    read -sp "Ingrese la contraseña de la base de datos: " DB_PASSWORD  # Solicitar contraseña sin mostrarla en pantalla.
    echo  # Imprimir una nueva línea para mejorar la legibilidad.
    read -sp "Ingrese la contraseña de root para MySQL: " ROOT_PASSWORD  # Solicitar contraseña de root sin mostrarla en pantalla.
    echo  
fi

# Exportar las variables para que Docker Compose pueda usarlas en su archivo de configuración.
export DB_USER 
export DB_PASSWORD  
export ROOT_PASSWORD  

# Ejecutar Docker Compose en segundo plano, levantando los servicios definidos en el archivo docker-compose.yml.
docker-compose up -d

```
