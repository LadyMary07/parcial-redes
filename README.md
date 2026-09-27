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

1. **Joomla**: Accesible en [http://localhost/](http://localhost/)
2. **Jupyter Notebook**: Accesible en [http://localhost/jupyter/](http://localhost/jupyter/)
   - *Token por defecto:* `jupyter_admin`
   - *Nota:* Ya incluye un cuaderno `analisis_datos.ipynb` precargado con análisis hacia la base de datos PostgreSQL.
3. **Grafana**: Accesible en [http://localhost/grafana/](http://localhost/grafana/)
   - *Usuario:* `admin`
   - *Contraseña:* `admin`
   - *Nota:* Incluye un Dashboard precargado y un datasource conectado directamente a PostgreSQL de manera inmutable (provisioning).

## Tecnologías Utilizadas
- Docker
- Nginx (Proxy Inverso y Enrutamiento)
- PostgreSQL (Persistencia y Segmentación)
- Joomla (CMS)
- Jupyter (Data Science)
- Grafana (Observabilidad y Monitoreo)
