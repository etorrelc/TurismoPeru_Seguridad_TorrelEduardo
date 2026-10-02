"""Genera un reporte HTML de clientes, reservas y pagos desde SQL Server.

Ejemplos:
    python app.py
    python app.py --output output/reporte.html
    python app.py --demo --output output/reporte_demo.html
"""
from __future__ import annotations

import argparse
import base64
import io
import os
from datetime import datetime, timedelta
from html import escape
from pathlib import Path

import matplotlib

# El reporte se ejecuta tambien en servidores y terminales sin interfaz grafica.
matplotlib.use("Agg")

import matplotlib.pyplot as plt
import pandas as pd
import pyodbc
from dotenv import load_dotenv


REPORT_QUERY = """
SELECT
    cliente_id, cliente_nombre, reserva_id, fecha_reserva, estado_reserva,
    pago_id, monto_pago, medio_pago
FROM dbo.vw_reporte_clientes_reservas_pagos;
"""
REQUIRED_COLUMNS = {
    "cliente_id", "cliente_nombre", "reserva_id", "fecha_reserva",
    "estado_reserva", "pago_id", "monto_pago", "medio_pago",
}


def connection_string() -> str:
    """Obtiene una conexion sin registrar secretos ni exponerlos en el codigo."""
    direct = os.getenv("DB_CONNECTION_STRING")
    if direct:
        return direct

    driver = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")
    server = os.getenv("DB_SERVER")
    database = os.getenv("DB_DATABASE")
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    trusted = os.getenv("DB_TRUSTED_CONNECTION", "yes").lower() in {"yes", "true", "1"}
    encrypt = os.getenv("DB_ENCRYPT", "yes")
    trust_cert = os.getenv("DB_TRUST_SERVER_CERTIFICATE", "no")

    if not server or not database:
        raise ValueError("Configure DB_SERVER y DB_DATABASE en el archivo .env.")
    if not trusted and (not user or not password):
        raise ValueError("Para autenticacion SQL configure DB_USER y DB_PASSWORD.")

    parts = [
        f"DRIVER={{{driver}}}",
        f"SERVER={server}",
        f"DATABASE={database}",
        f"Encrypt={encrypt}",
        f"TrustServerCertificate={trust_cert}",
    ]
    if trusted:
        parts.append("Trusted_Connection=yes")
    else:
        parts.extend([f"UID={user}", f"PWD={password}"])
    return ";".join(parts)


def load_data(demo: bool) -> pd.DataFrame:
    if demo:
        return demo_data()
    with pyodbc.connect(connection_string(), timeout=30) as connection:
        data = pd.read_sql(REPORT_QUERY, connection)
    missing = REQUIRED_COLUMNS.difference(data.columns)
    if missing:
        raise ValueError(f"La vista no entrega las columnas requeridas: {', '.join(sorted(missing))}.")
    return data


def demo_data() -> pd.DataFrame:
    """Datos no productivos para comprobar la generacion visual sin conectarse a SQL Server."""
    rows: list[dict[str, object]] = []
    clients = ["Ana Ruiz", "Bruno Perez", "Carla Diaz", "Diego Flores", "Elena Soto"]
    states = ["Confirmada", "Pendiente", "Confirmada", "Cancelada", "Confirmada"]
    methods = ["Tarjeta", "Yape", "Transferencia", "Tarjeta", "Efectivo"]
    for number in range(1, 21):
        client_id = (number - 1) % len(clients) + 1
        rows.append({
            "cliente_id": client_id,
            "cliente_nombre": clients[client_id - 1],
            "reserva_id": number,
            "fecha_reserva": datetime(2026, 1, 1) + timedelta(days=number * 8),
            "estado_reserva": states[(number - 1) % len(states)],
            "pago_id": number,
            "monto_pago": float(150 + (number % 6) * 75),
            "medio_pago": methods[(number - 1) % len(methods)],
        })
    return pd.DataFrame(rows)


def image_data_uri(figure: plt.Figure) -> str:
    buffer = io.BytesIO()
    figure.tight_layout()
    figure.savefig(buffer, format="png", dpi=160, bbox_inches="tight")
    plt.close(figure)
    return "data:image/png;base64," + base64.b64encode(buffer.getvalue()).decode("ascii")


def chart(series: pd.Series, title: str, ylabel: str, color: str = "#0f766e") -> str:
    figure, axis = plt.subplots(figsize=(8, 4.2))
    series.plot(kind="bar", ax=axis, color=color)
    axis.set_title(title, fontweight="bold")
    axis.set_xlabel("")
    axis.set_ylabel(ylabel)
    axis.tick_params(axis="x", rotation=30)
    axis.grid(axis="y", alpha=0.25)
    return image_data_uri(figure)


def money(value: float) -> str:
    return f"S/ {value:,.2f}"


def analyse(data: pd.DataFrame) -> tuple[dict[str, object], dict[str, pd.Series], list[str]]:
    data = data.copy()
    data["fecha_reserva"] = pd.to_datetime(data["fecha_reserva"], errors="coerce")
    data["monto_pago"] = pd.to_numeric(data["monto_pago"], errors="coerce").fillna(0)
    reservations = data.dropna(subset=["reserva_id"]).drop_duplicates("reserva_id")
    payments = data.dropna(subset=["pago_id"]).drop_duplicates("pago_id")

    total_clients = int(data["cliente_id"].dropna().nunique())
    total_reservations = int(reservations["reserva_id"].nunique())
    total_income = float(payments["monto_pago"].sum())
    average_ticket = total_income / total_reservations if total_reservations else 0.0

    by_state = reservations["estado_reserva"].fillna("Sin estado").value_counts()
    by_method = payments.groupby(payments["medio_pago"].fillna("Sin medio"))["monto_pago"].sum().sort_values(ascending=False)
    by_period = reservations.dropna(subset=["fecha_reserva"]).groupby(reservations["fecha_reserva"].dt.to_period("M")).size()
    by_period.index = by_period.index.astype(str)
    top_clients = reservations.groupby("cliente_nombre")["reserva_id"].nunique().sort_values(ascending=False).head(10)
    income_by_client = payments.groupby("cliente_nombre")["monto_pago"].sum().sort_values(ascending=False).head(10)

    conclusions = [
        f"Se identificaron {total_clients} clientes con actividad en el periodo analizado.",
        f"Las reservas registradas suman {total_reservations} y el ticket promedio es {money(average_ticket)}.",
    ]
    if not by_state.empty:
        conclusions.append(f"El estado con mas reservas es {by_state.index[0]} con {int(by_state.iloc[0])} reservas.")
    if not by_method.empty:
        conclusions.append(f"El medio de pago que concentra mayores ingresos es {by_method.index[0]} con {money(float(by_method.iloc[0]))}.")
    if not income_by_client.empty:
        conclusions.append(f"El cliente con mayor ingreso acumulado es {income_by_client.index[0]} con {money(float(income_by_client.iloc[0]))}.")

    metrics = {
        "Total clientes": total_clients,
        "Total reservas": total_reservations,
        "Total ingresos": money(total_income),
        "Ticket promedio": money(average_ticket),
    }
    charts = {
        "Reservas por estado": by_state,
        "Ingresos por medio de pago": by_method,
        "Reservas por periodo": by_period,
        "Top 10 clientes por reservas": top_clients,
        "Ingresos por cliente": income_by_client,
    }
    return metrics, charts, conclusions


def build_html(data: pd.DataFrame, demo: bool) -> str:
    metrics, charts, conclusions = analyse(data)
    chart_images = [
        (title, chart(values, title, "Ingresos (S/)" if "Ingresos" in title else "Reservas", "#2563eb" if "Ingresos" in title else "#0f766e"))
        for title, values in charts.items()
    ]
    cards = "".join(f"<article><span>{escape(str(name))}</span><strong>{escape(str(value))}</strong></article>" for name, value in metrics.items())
    images = "".join(f"<section class='chart'><h2>{escape(title)}</h2><img src='{uri}' alt='{escape(title)}'></section>" for title, uri in chart_images)
    conclusion_items = "".join(f"<li>{escape(item)}</li>" for item in conclusions)
    preview = data.head(20).copy()
    if "monto_pago" in preview:
        preview["monto_pago"] = preview["monto_pago"].map(lambda value: money(float(value)) if pd.notna(value) else "")
    table = preview.to_html(index=False, classes="data", border=0, escape=True)
    note = "Datos de demostracion: no representan la base de datos real." if demo else "Fuente: SQL Server, vista dbo.vw_reporte_clientes_reservas_pagos."
    generated = datetime.now().strftime("%Y-%m-%d %H:%M")
    return f"""<!doctype html>
<html lang='es'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1'>
<title>Reporte TurismoPeru</title><style>
body{{font-family:Arial,sans-serif;max-width:1200px;margin:auto;padding:28px;background:#f8fafc;color:#0f172a}}
h1{{margin-bottom:4px}} .muted{{color:#475569}} .cards{{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin:24px 0}}
article,.chart{{background:white;border:1px solid #e2e8f0;border-radius:10px;padding:18px}} article span{{display:block;color:#475569}} article strong{{display:block;font-size:1.55rem;margin-top:8px}}
.charts{{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px}} .chart img{{width:100%;height:auto}} .data{{width:100%;border-collapse:collapse;background:white}} .data th,.data td{{padding:8px;border:1px solid #e2e8f0;text-align:left}} .data th{{background:#e2e8f0}} @media(max-width:760px){{.cards,.charts{{grid-template-columns:1fr}}}}
</style></head><body><h1>Reporte analitico TurismoPeru</h1><p class='muted'>{escape(note)} Generado: {generated}.</p>
<div class='cards'>{cards}</div><h2>Visualizaciones</h2><div class='charts'>{images}</div>
<h2>Conclusiones</h2><ol>{conclusion_items}</ol><h2>Muestra de datos</h2>{table}</body></html>"""


def main() -> None:
    parser = argparse.ArgumentParser(description="Genera el reporte HTML de TurismoPeru.")
    parser.add_argument("--demo", action="store_true", help="Usa datos de prueba, sin conectarse a SQL Server.")
    parser.add_argument("--output", default="output/reporte.html", help="Ruta del HTML de salida.")
    args = parser.parse_args()
    load_dotenv(Path(__file__).with_name(".env"))
    output = Path(args.output)
    if not output.is_absolute():
        output = Path(__file__).parent / output
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(build_html(load_data(args.demo), args.demo), encoding="utf-8")
    print(f"Reporte generado en: {output}")


if __name__ == "__main__":
    main()
