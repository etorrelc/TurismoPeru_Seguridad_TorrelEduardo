/*
  Permisos de minimo privilegio.
  Si las tablas estan en otro esquema, por ejemplo turismo, reemplace dbo.
  Ejecutar con sqlcmd -v TableSchema="dbo"
*/
USE [TURISMOPERU_EMTC_V4];
GO

/* Vendedor: solo consulta y registra clientes y reservas. */
GRANT SELECT, INSERT ON OBJECT::[$(TableSchema)].[cliente] TO [rol_vendedor];
GRANT SELECT, INSERT ON OBJECT::[$(TableSchema)].[reserva] TO [rol_vendedor];
GRANT SELECT ON OBJECT::[$(TableSchema)].[alojamiento] TO [rol_vendedor];
GRANT SELECT ON OBJECT::[$(TableSchema)].[habitacion] TO [rol_vendedor];
DENY DELETE ON OBJECT::[$(TableSchema)].[cliente] TO [rol_vendedor];
DENY DELETE ON OBJECT::[$(TableSchema)].[reserva] TO [rol_vendedor];
GO

/* Analista: solo lectura sobre las entidades necesarias para sus reportes. */
GRANT SELECT ON OBJECT::[$(TableSchema)].[cliente] TO [rol_analista];
GRANT SELECT ON OBJECT::[$(TableSchema)].[reserva] TO [rol_analista];
GRANT SELECT ON OBJECT::[$(TableSchema)].[pago] TO [rol_analista];
GRANT SELECT ON OBJECT::[$(TableSchema)].[alojamiento] TO [rol_analista];
GRANT SELECT ON OBJECT::[$(TableSchema)].[habitacion] TO [rol_analista];
GRANT SELECT ON OBJECT::[$(TableSchema)].[paquete] TO [rol_analista];
GRANT SELECT ON OBJECT::[$(TableSchema)].[lugar_turistico] TO [rol_analista];

DENY INSERT, UPDATE, DELETE ON OBJECT::[$(TableSchema)].[cliente] TO [rol_analista];
DENY INSERT, UPDATE, DELETE ON OBJECT::[$(TableSchema)].[reserva] TO [rol_analista];
DENY INSERT, UPDATE, DELETE ON OBJECT::[$(TableSchema)].[pago] TO [rol_analista];
DENY INSERT, UPDATE, DELETE ON OBJECT::[$(TableSchema)].[alojamiento] TO [rol_analista];
DENY INSERT, UPDATE, DELETE ON OBJECT::[$(TableSchema)].[habitacion] TO [rol_analista];
DENY INSERT, UPDATE, DELETE ON OBJECT::[$(TableSchema)].[paquete] TO [rol_analista];
DENY INSERT, UPDATE, DELETE ON OBJECT::[$(TableSchema)].[lugar_turistico] TO [rol_analista];
GO

/* Ningun rol funcional recibe permisos para administrar logins, usuarios, roles o backups. */
SELECT dp.name AS principal, dp.type_desc
FROM sys.database_principals AS dp
WHERE dp.name IN (N'rol_vendedor', N'rol_analista');
GO
