# Reporte Python

Este modulo consulta SQL Server y crea un reporte HTML con indicadores, graficos, tabla de muestra y cinco conclusiones calculadas a partir de los datos.

## Configuracion

1. Cree un entorno virtual: `python -m venv venv`.
2. Active el entorno e instale dependencias: `pip install -r requirements.txt`.
3. Copie `.env.example` como `.env` y complete los datos de conexion. El archivo `.env` esta excluido por Git.
4. Ejecute `05_reportes/consultas_reportes.sql` en SSMS para crear la vista `EMTC_V4.vw_reporte_clientes_reservas_pagos`.
5. Ejecute `python app.py --output output/reporte.html`.

Para validar la presentacion sin conectarse a SQL Server, ejecute `python app.py --demo`. Los datos de esa opcion son solo de prueba y no deben usarse como evidencia final.

El archivo se genera en `output/reporte.html`. Abra ese HTML en un navegador y tome la captura requerida para `evidencias/reporte.png` despues de ejecutarlo con datos reales.
