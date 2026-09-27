# Informe Técnico - Arquitectura y Análisis del Modelo OSI

## Sección 1: Topología y Flujo de Información

### Diagrama de Arquitectura

El ecosistema cuenta con 5 contenedores docker comunicándose mediante dos redes virtuales aisladas.

* **Nginx** actúa como *Edge Router* (puerto 80) y expone Joomla (raíz `/`), Jupyter (`/jupyter`) y Grafana (`/grafana`).
* **Jupyter** se conecta al backend para las consultas a la base de datos.
* **Grafana** consulta la actividad directamente en PostgreSQL para recolectar métricas de la base de datos que aloja Joomla.

### Mecanismo de Recolección de Logs / Métricas
La recolección de métricas se realiza conectando directamente **Grafana** a la base de datos **PostgreSQL**. Se configuró un datasource automatizado mediante archivos YAML (Provisioning). Para no requerir de pasos manuales, los dashboards ejecutan consultas a las vistas del sistema `pg_stat_database` para recolectar, de forma desatendida y persistente, datos de transacciones, uso, y volumen de registros.

---

## Sección 2: Análisis Detallado del Modelo OSI

### Capa 7 (Aplicación)
- **Cabeceras HTTP de Nginx:** Nginx inyecta cabeceras de proxy inverso (Host, X-Forwarded-For, X-Forwarded-Proto) permitiendo que los servicios backend conozcan la IP real del cliente que inició la petición.
- **HTTP Upgrade:** En Nginx se emplean las directivas `proxy_set_header Upgrade $http_upgrade;` y `Connection "upgrade";`. Estas interceptan el handshake HTTP tradicional y permiten la transición a WebSockets bidireccionales, que son esenciales para el kernel y la consola en Jupyter.
- **Protocolos Cliente/Servidor:** PostgreSQL utiliza su propio protocolo de aplicación TCP. Joomla, al generar y procesar peticiones, se comunica contra la base de datos como cliente.

### Capa 4 (Transporte)
- **Puertos TCP:** Se exponen únicamente puertos internos entre contenedores (5432 para Postgres, 3000 Grafana, 8888 Jupyter). Únicamente Nginx publica el `80` hacia el exterior.
- **Conexiones Concurrentes y Persistentes:** PostgreSQL y los motores WSGI (Jupyter) manejan multiplexación de conexiones. Utilizan el mecanismo *keep-alive* para mantener los sockets TCP abiertos y realizar *connection pooling*, optimizando la transferencia de consultas de Joomla y los dashboards de Grafana hacia la DB sin reabrir conexiones de capa 4.

### Capa 3 (Red)
- **Direccionamiento IP y Aislamiento:** El entorno define dos puentes de red (`frontend_net` y `backend_net`). El contenedor `database` pertenece **solo** a `backend_net` y dicha red se configuró con `internal: true`. Por ello, la base de datos tiene total aislamiento lógico: ni interactúa con la red exterior ni es alcanzable a través del host.
- **Resolución DNS Embebida (127.0.0.11):** Docker proporciona un servidor DNS embebido. Este intercepta resoluciones de nombre ("database", "joomla") a sus correspondientes IPs virtuales, permitiendo un direccionamiento agnóstico.
- **Reglas de Reenvío (NAT):** El kernel del host Linux/Windows maneja automáticamente reglas `iptables`/NAT para enrutar el tráfico entrante al puerto 80 del Nginx.

### Capa 2 (Enlace de Datos)
- **Interfaces Virtuales (veth*):** Cada contenedor se engancha a su respectivo bridge con pares `veth`. Cuando `joomla` habla con `database`, las tramas Ethernet viajan del veth de Joomla al switch virtual (br-*) correspondiente a `backend_net`.
- **Resolución ARP Interna:** Los contenedores en el mismo bridge resuelven las MAC addresses de sus destinos por medio de ARP normal encapsulado en el switch virtual de Docker.

---

## Sección 3: Guía de Verificación y Demostración

Para validar el ecosistema:

1. Levantar con `docker compose up -d` y esperar aproximadamente 30-40 segundos para que PostgreSQL asuma el estado "healthy" y todos los servicios dependientes arranquen.
2. Navegar a [http://localhost/](http://localhost/) (Joomla) y generar navegación básica por el sitio.
3. Navegar a [http://localhost/grafana/](http://localhost/grafana/), iniciar sesión con admin/admin. Entrar a Dashboards -> "Joomla Dashboards". Verificar las dos gráficas de series temporales que muestran el crecimiento de transacciones y uso de PostgreSQL.
4. Navegar a [http://localhost/jupyter/](http://localhost/jupyter/) usando la contraseña `jupyter_admin`. Entrar a `work/` -> `analisis_datos.ipynb` y ejecutar (Shift+Enter) todas las celdas de Python. Verificar que se instalen las dependencias `psycopg2-binary` e imprima satisfactoriamente la tabla que extrae del PostgreSQL.
