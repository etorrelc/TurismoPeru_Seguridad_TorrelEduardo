/*
  Vista de consumo para el reporte Python.
  Modelo esperado: cliente -> persona, cliente -> reserva, reserva -> pago.
  Ajuste los nombres de claves y columnas si su base de datos usa otra nomenclatura.
*/
USE [TURISMOPERU_EMTC_V4];
GO

CREATE OR ALTER VIEW EMTC_V4.vw_reporte_clientes_reservas_pagos
AS
SELECT
    c.id_persona AS cliente_id,
    LTRIM(RTRIM(CONCAT(
        ISNULL(p.nombres, N''), N' ',
        ISNULL(p.apaterno, N''), N' ',
        ISNULL(p.amaterno, N'')
    ))) AS cliente_nombre,
    r.id_reserva AS reserva_id,
    r.fecha_reserva AS fecha_reserva,
    er.nombre AS estado_reserva,
    pg.id_pago AS pago_id,
    CAST(pg.monto AS DECIMAL(18, 2)) AS monto_pago,
    mp.nombre AS medio_pago
FROM EMTC_V4.cliente AS c
INNER JOIN EMTC_V4.persona AS p ON p.id_persona = c.id_persona
LEFT JOIN EMTC_V4.reserva AS r ON r.id_cliente = c.id_persona
LEFT JOIN EMTC_V4.estado_reserva AS er ON er.id_estado_reserva = r.id_estado_reserva
LEFT JOIN EMTC_V4.pago AS pg ON pg.id_reserva = r.id_reserva
LEFT JOIN EMTC_V4.medio_pago AS mp ON mp.id_medio_pago = pg.id_medio_pago;
GO

SELECT TOP (20) *
FROM EMTC_V4.vw_reporte_clientes_reservas_pagos
ORDER BY fecha_reserva DESC;
GO
