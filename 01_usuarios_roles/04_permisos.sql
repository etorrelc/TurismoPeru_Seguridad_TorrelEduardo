/*
  Permisos de minimo privilegio.
  Las tablas del sistema estan en el esquema [EMTC_V4].
  Ejecutar directamente en SQL Server Management Studio (SSMS).
*/
USE [TURISMOPERU_EMTC_V4];
GO

/* Vendedor: solo consulta y registra clientes y reservas. */
GRANT SELECT, INSERT ON OBJECT::[EMTC_V4].[cliente] TO [rol_vendedor];
GRANT SELECT, INSERT ON OBJECT::[EMTC_V4].[reserva] TO [rol_vendedor];
GRANT SELECT ON OBJECT::[EMTC_V4].[alojamiento] TO [rol_vendedor];
GRANT SELECT ON OBJECT::[EMTC_V4].[habitacion] TO [rol_vendedor];
DENY DELETE ON OBJECT::[EMTC_V4].[cliente] TO [rol_vendedor];
DENY DELETE ON OBJECT::[EMTC_V4].[reserva] TO [rol_vendedor];
GO

/* Analista: solo lectura sobre las entidades necesarias para sus reportes. */
GRANT SELECT ON OBJECT::[EMTC_V4].[cliente] TO [rol_analista];
GRANT SELECT ON OBJECT::[EMTC_V4].[reserva] TO [rol_analista];
GRANT SELECT ON OBJECT::[EMTC_V4].[pago] TO [rol_analista];
GRANT SELECT ON OBJECT::[EMTC_V4].[alojamiento] TO [rol_analista];
GRANT SELECT ON OBJECT::[EMTC_V4].[habitacion] TO [rol_analista];
GRANT SELECT ON OBJECT::[EMTC_V4].[paquete] TO [rol_analista];
GRANT SELECT ON OBJECT::[EMTC_V4].[lugar_turistico] TO [rol_analista];

DENY INSERT, UPDATE, DELETE ON OBJECT::[EMTC_V4].[cliente] TO [rol_analista];
DENY INSERT, UPDATE, DELETE ON OBJECT::[EMTC_V4].[reserva] TO [rol_analista];
DENY INSERT, UPDATE, DELETE ON OBJECT::[EMTC_V4].[pago] TO [rol_analista];
DENY INSERT, UPDATE, DELETE ON OBJECT::[EMTC_V4].[alojamiento] TO [rol_analista];
DENY INSERT, UPDATE, DELETE ON OBJECT::[EMTC_V4].[habitacion] TO [rol_analista];
DENY INSERT, UPDATE, DELETE ON OBJECT::[EMTC_V4].[paquete] TO [rol_analista];
DENY INSERT, UPDATE, DELETE ON OBJECT::[EMTC_V4].[lugar_turistico] TO [rol_analista];
GO

/* Ningun rol funcional recibe permisos para administrar logins, usuarios, roles o backups. */
SELECT dp.name AS principal, dp.type_desc
FROM sys.database_principals AS dp
WHERE dp.name IN (N'rol_vendedor', N'rol_analista');
GO
