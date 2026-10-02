param(
    [string]$Servidor = ".",
    [string]$BaseDatos = "TURISMOPERU_EMTC_V4",
    [string]$DirectorioSalida = "$PSScriptRoot\datos\exportados"
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path $DirectorioSalida | Out-Null

function Exportar-Csv {
    param(
        [string]$NombreArchivo,
        [string]$Encabezado,
        [string]$Consulta
    )

    $archivo = Join-Path $DirectorioSalida $NombreArchivo
    $temporal = "$archivo.tmp"

    Set-Content -LiteralPath $archivo -Value $Encabezado -Encoding utf8
    & bcp $Consulta queryout $temporal -S $Servidor -d $BaseDatos -T -c -C 65001 -t "," -r "\n" -u

    if ($LASTEXITCODE -ne 0) {
        throw "BCP no pudo exportar $NombreArchivo."
    }

    Get-Content -LiteralPath $temporal -Encoding utf8 | Add-Content -LiteralPath $archivo -Encoding utf8
    Remove-Item -LiteralPath $temporal
    Write-Host "Creado: $archivo"
}

Exportar-Csv -NombreArchivo "clientes.csv" `
    -Encabezado "Documento,Nombres,ApellidoPaterno,ApellidoMaterno,FechaNacimiento" `
    -Consulta @"
SELECT p.numero_documento, p.nombres, p.apaterno, p.amaterno, c.fecha_nacimiento
FROM EMTC_V4.cliente AS c
INNER JOIN EMTC_V4.persona AS p ON p.id_persona = c.id_persona
ORDER BY p.numero_documento
"@

Exportar-Csv -NombreArchivo "alojamientos.csv" `
    -Encabezado "id_alojamiento,id_tipoalojamiento,Nombre,Telefono,Email,Categoria_Estrellas" `
    -Consulta @"
SELECT id_alojamiento, id_tipoalojamiento, Nombre, Telefono, Email, Categoria_Estrellas
FROM EMTC_V4.alojamiento
ORDER BY id_alojamiento
"@

Exportar-Csv -NombreArchivo "habitaciones.csv" `
    -Encabezado "id_habitacion,id_persona,id_alojamiento,numero_habitacion,id_tipo_habitacion,precio_noche,estado,descripcion" `
    -Consulta @"
SELECT id_habitacion, id_persona, id_alojamiento, numero_habitacion, id_tipo_habitacion,
       precio_noche, estado, descripcion
FROM EMTC_V4.habitacion
ORDER BY id_habitacion
"@

Exportar-Csv -NombreArchivo "lugares_turisticos.csv" `
    -Encabezado "id_lugarturistico,nombre,descripcion,precio_entrada,horario_apertura,horario_cierre,calificacion,estado" `
    -Consulta @"
SELECT id_lugarturistico, nombre, descripcion, precio_entrada, horario_apertura,
       horario_cierre, calificacion, estado
FROM EMTC_V4.lugar_turistico
ORDER BY id_lugarturistico
"@

Exportar-Csv -NombreArchivo "pagos.csv" `
    -Encabezado "id_pago,id_reserva,id_medio_pago,monto,fecha_pago,numero_operacion,comprobante,estado" `
    -Consulta @"
SELECT id_pago, id_reserva, id_medio_pago, monto, fecha_pago, numero_operacion,
       comprobante, estado
FROM EMTC_V4.pago
ORDER BY id_pago
"@

Exportar-Csv -NombreArchivo "paquetes.csv" `
    -Encabezado "id_paquete,nombre,descripcion,id_tipo_paquete,duracion_dias,duracion_noches,precio_base,precio_por_persona_adicional,capacidad_minima,capacidad_maxima,incluye_hospedaje,incluye_transporte,incluye_alimentacion,incluye_guia,estado,fecha_creacion" `
    -Consulta @"
SELECT id_paquete, nombre, descripcion, id_tipo_paquete, duracion_dias, duracion_noches,
       precio_base, precio_por_persona_adicional, capacidad_minima, capacidad_maxima,
       incluye_hospedaje, incluye_transporte, incluye_alimentacion, incluye_guia,
       estado, fecha_creacion
FROM EMTC_V4.paquete
ORDER BY id_paquete
"@

Exportar-Csv -NombreArchivo "reservas.csv" `
    -Encabezado "id_reserva,codigo_reserva,id_cliente,id_paquete,id_empleado,id_alojamiento,id_habitacion,fecha_reserva,fecha_inicio,fecha_fin,numero_personas,precio_total,adelanto,saldo_pendiente,id_estado_reserva,observaciones" `
    -Consulta @"
SELECT id_reserva, codigo_reserva, id_cliente, id_paquete, id_empleado, id_alojamiento,
       id_habitacion, fecha_reserva, fecha_inicio, fecha_fin, numero_personas,
       precio_total, adelanto, saldo_pendiente, id_estado_reserva, observaciones
FROM EMTC_V4.reserva
ORDER BY id_reserva
"@

Write-Host "Exportacion terminada en: $DirectorioSalida"
