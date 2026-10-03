# Parcial 2 Práctico: Despliegue Multi-contenedor

Este repositorio contiene la solución del parcial práctico de Comunicaciones, desplegando una infraestructura web con Nginx, Joomla, PostgreSQL, Jupyter y Grafana.

## Requisitos Previos

- Docker y Docker Compose instalados.
- Puertos `80` disponibles en el host.

## Despliegue Desatendido (Zero-Touch)

Para desplegar todos los servicios de una sola vez, ejecuta los siguientes comandos en la raíz de este repositorio:

```bash
cp .env.example .env
docker compose up -d
```

## Servicios Expuestos

1. **Joomla (Sitio Web Principal)**: Accesible en [http://localhost/](http://localhost/)
   - *Nota:* Joomla se autoconfigura al iniciar e incluye un panel de accesos directos al resto de las herramientas.
2. **Jupyter Notebook (Análisis de Datos)**: Accesible en [http://localhost/jupyter/](http://localhost/jupyter/)
   - *Autenticación:* Abierto (Token deshabilitado para desarrollo local).
   - *Nota:* Ya incluye un cuaderno `analisis_datos.ipynb` precargado y ejecutado con análisis de las tablas de PostgreSQL. Las librerías de Python ya vienen embebidas en la imagen.
3. **Grafana (Monitoreo y Métricas)**: Accesible en [http://localhost/grafana/](http://localhost/grafana/)
   - *Usuario / Contraseña:* `admin` / `admin`
   - *Nota:* Incluye un Dashboard precargado y un datasource conectado directamente a PostgreSQL de manera inmutable (provisioning). No es necesario realizar configuraciones manuales.

## Tecnologías Utilizadas
- Docker
- Nginx (Proxy Inverso y Enrutamiento)
- PostgreSQL (Persistencia y Segmentación)
- Joomla (CMS)
- Jupyter (Data Science)
- Grafana (Observabilidad y Monitoreo)

## Estructura del Proyecto

```text
.
├── GUIA_PARCIAL.md         # Instrucciones y rúbrica
├── INFORME.md              # Documentación técnica y análisis OSI
├── README.md               # Este archivo
├── docker-compose.yml      # Orquestación de contenedores
├── escudo.svg              # Recurso gráfico inyectado en Joomla
├── grafana/                # Dashboards y datasources aprovisionados
├── jupyter/                # Dockerfile e imágenes con cuadernos
├── nginx/                  # Reglas del proxy reverso (Edge Router)
└── setup-joomla.sh         # Script sidecar de automatización Zero-Touch
```
