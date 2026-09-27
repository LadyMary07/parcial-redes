# Guía Paso a Paso: Parcial de Redes y Comunicaciones

Este documento explica cómo construir desde cero la infraestructura de microservicios solicitada en el parcial, cumpliendo con los requisitos de segmentación de red, orquestación y aprovisionamiento automático (Zero-Touch).

---

## FASE 1: Preparación del Entorno

1. **Instalar Docker Desktop**: Es el motor que correrá todos los contenedores.
2. **Instalar Git**: Para el control de versiones y subida del código a GitHub.
3. **Crear el directorio del proyecto**: Se crea una carpeta llamada `parcial-redes` que contendrá toda la configuración.

---

## FASE 2: Archivo de Orquestación (`docker-compose.yml`)

El corazón del proyecto es el archivo `docker-compose.yml`. Aquí definimos nuestros 5 contenedores y 2 redes virtuales.

### 1. Las Redes (Capa 2 y 3 del Modelo OSI)
Definimos dos redes para segmentar el tráfico:
* `frontend_net`: Red puente normal para servicios expuestos.
* `backend_net`: Red **interna** (`internal: true`). La base de datos vive aquí, impidiendo que internet acceda a ella directamente por seguridad.

### 2. Los Contenedores
1. **Database (PostgreSQL 16)**: Conectado *solo* a la `backend_net`. Se le inyectan variables de entorno (usuario, contraseña y BD).
2. **Joomla (Aplicación CMS)**: Conectado a ambas redes. Recibe tráfico del frontend y se conecta a la base de datos en el backend.
3. **Jupyter (Análisis de Datos)**: Se expone en el puerto 8888 pero a través de Nginx. Monta un volumen local (`./jupyter/notebooks`) para inyectar el código de Python automáticamente.
4. **Grafana (Monitoreo)**: Conectado a ambas redes. Monta la carpeta `./grafana/provisioning` para leer las conexiones sin intervención humana.
5. **Nginx (Proxy Inverso)**: Conectado a `frontend_net`. Es el único que expone el puerto `80` al exterior.

---

## FASE 3: Configuración del Proxy Inverso (Nginx)

Se crea el archivo `nginx/default.conf` para enrutar el tráfico HTTP de forma inteligente:
* Tráfico a `/` ➔ Se redirige a Joomla (puerto 80).
* Tráfico a `/grafana/` ➔ Se redirige a Grafana (puerto 3000).
* Tráfico a `/jupyter/` ➔ Se redirige a Jupyter (puerto 8888). 
  *(Para Jupyter se agregan cabeceras `Upgrade` y `Connection "upgrade"` para soportar los WebSockets que Python necesita para ejecutar celdas en tiempo real).*

---

## FASE 4: Aprovisionamiento Automático (Zero-Touch)

Para cumplir con la rúbrica de no obligar al profesor a configurar nada a mano:

### 1. Grafana
En lugar de abrir Grafana y configurar la conexión, creamos:
* `grafana/provisioning/datasources/datasource.yml`: Le dice a Grafana cómo conectarse a PostgreSQL (`database:5432`) inyectándole las credenciales automáticamente.
* `grafana/provisioning/dashboards/dashboard.yml` y `joomla_logs.json`: Inyecta un tablero con 9 paneles preconfigurados (Gráficas de líneas, pasteles, medidores y estadísticas en bloque) usando consultas SQL directas a `pg_stat_database`.

### 2. Jupyter Notebook
Creamos `jupyter/notebooks/analisis_datos.ipynb`. Este cuaderno contiene código Python usando la librería `pandas` y `psycopg2` para conectarse a PostgreSQL, extraer el tamaño de las tablas de Joomla y mostrarlas de forma interactiva. 

---

## FASE 5: Despliegue y Ejecución

Con todos los archivos listos, se abre la terminal en la carpeta del proyecto y se ejecuta:
```bash
docker compose up -d
```
Docker descargará las imágenes, creará las redes, asignará IPs, montará los volúmenes y encenderá los 5 contenedores en el orden correcto (respetando los `depends_on` configurados).

---

## FASE 6: Uso y Pruebas del Sistema

1. **Joomla (`http://localhost/`)**: Se abre en el navegador y se completa la configuración web (título del sitio y credenciales).
2. **Jupyter (`http://localhost/jupyter`)**: Se abre el cuaderno pre-cargado y se presiona "Ejecutar todo". Mostrará el tamaño en kilobytes de cada tabla.
3. **Grafana (`http://localhost/grafana`)**: Se ingresa con admin/admin y se abre el "Joomla Dashboard" para ver las transacciones en tiempo real.

---

## FASE 7: Control de Versiones

Finalmente, para empaquetar el proyecto, se ejecuta:
```bash
git init
git add .
git commit -m "Entrega final del parcial"
git push -u origin master
```
El proyecto queda 100% disponible en la nube para ser clonado y ejecutado por el docente en un solo paso.
