/*
  Vista de consumo para el reporte Python.
  Modelo esperado: cliente -> persona, cliente -> reserva, reserva -> pago.
  Ajuste los nombres de claves y columnas si su base de datos usa otra nomenclatura.
*/
USE [$(DatabaseName)];
GO

CREATE OR ALTER VIEW dbo.vw_reporte_clientes_reservas_pagos
AS
SELECT
    c.IdCliente AS cliente_id,
    LTRIM(RTRIM(CONCAT(
        ISNULL(p.Nombres, N''), N' ',
        ISNULL(p.ApellidoPaterno, N''), N' ',
        ISNULL(p.ApellidoMaterno, N'')
    ))) AS cliente_nombre,
    r.IdReserva AS reserva_id,
    r.FechaReserva AS fecha_reserva,
    r.Estado AS estado_reserva,
    pg.IdPago AS pago_id,
    CAST(pg.Monto AS DECIMAL(18, 2)) AS monto_pago,
    pg.MedioPago AS medio_pago
FROM dbo.cliente AS c
INNER JOIN dbo.persona AS p ON p.IdPersona = c.IdPersona
LEFT JOIN dbo.reserva AS r ON r.IdCliente = c.IdCliente
LEFT JOIN dbo.pago AS pg ON pg.IdReserva = r.IdReserva;
GO

SELECT TOP (20) *
FROM dbo.vw_reporte_clientes_reservas_pagos
ORDER BY fecha_reserva DESC;
GO
