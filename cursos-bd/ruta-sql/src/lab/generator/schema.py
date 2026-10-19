"""El esquema de ALAMEDA tal como lo dejó SQL Server: una lista de tablas con sus columnas en T-SQL.

De aquí salen tres cosas: el encabezado de cada CSV de la caja, el script de creación que trae la
caja (`esquema/ALAMEDA.sql`, como lo habría generado SSMS) y los tipos con los que `lab load` crea
el esquema `legacy` en cada motor.
"""

import re
from dataclasses import dataclass, field

from .names import WIDE_FROM_PRACTICE, WIDE_OTHERS

FIRST_PRICE_MONTH = (2002, 9)
LAST_PRICE_MONTH = (2025, 12)


@dataclass(frozen=True)
class Column:
    name: str
    tsql: str                     # tipo tal como lo escribe SSMS: "nvarchar(255)", "datetime"…
    identity: str = ""            # "IDENTITY(1,1)" si la columna lo es
    exported: bool = True         # las imágenes y los PDF no viajan en la caja


@dataclass
class Table:
    name: str
    columns: list[Column]
    primary_key: str | None = None
    encoding: str = "utf-8"       # dos tablas salieron en Latin-1, "porque así salieron"
    group: str = "core"           # core · wide · prices · unknown
    foreign_keys: list[tuple[str, str, str]] = field(default_factory=list)   # (columna, tabla, columna), WITH NOCHECK

    @property
    def exported_columns(self) -> list[Column]:
        return [c for c in self.columns if c.exported]

    @property
    def file(self) -> str:
        return f"tablas/{self.name}.csv"


def _c(spec: str) -> list[Column]:
    """'IdPaciente int+, Nombre nvarchar(255)' → columnas; '+' marca IDENTITY(1,1), '!' no exportada."""
    out = []
    for part in re.split(r",\s*(?![^()]*\))", spec):
        name, tsql = part.strip().rsplit(" ", 1)
        identity = "IDENTITY(1,1)" if tsql.endswith("+") else ""
        exported = not tsql.endswith("!")
        out.append(Column(name.strip(), tsql.rstrip("+!"), identity, exported))
    return out


def _core() -> list[Table]:
    t = [
        Table("Pacientes", _c("IdPaciente int+, Nombre nvarchar(255), DNI nvarchar(50), FechaNac datetime, "
                              "Edad nvarchar(50), Sexo nvarchar(1), Telefono nvarchar(255), Direccion nvarchar(255), "
                              "ObraSocial nvarchar(255), NroAfiliado nvarchar(50), Sede nvarchar(1), FechaAlta datetime"),
              "IdPaciente", encoding="latin-1"),
        Table("Protocolos", _c("IdProtocolo int, NroProtocolo nvarchar(20), IdPaciente int, Fecha datetime, "
                               "Sede nvarchar(1), ObraSocial nvarchar(255), IdObraSocial int, IdMedico int, "
                               "Coseguro money, Estado nvarchar(20), OrdenEscaneada image!, InformePDF varbinary(max)!"),
              "IdProtocolo", foreign_keys=[("IdPaciente", "Pacientes", "IdPaciente"),
                                           ("IdObraSocial", "ObrasSociales", "IdObraSocial")]),
        Table("ProtocoloPracticas", _c("Id int+, IdProtocolo int, CodigoPractica nvarchar(20), "
                                       "Nomenclador nvarchar(10), Cantidad int"), "Id"),
        Table("Practicas", _c("IdPractica int+, CodINOS nvarchar(20), CodNBU nvarchar(20), CodNBU2012 nvarchar(20), "
                              "Descripcion nvarchar(255), UB decimal(8,2)"), "IdPractica"),
        Table("EquivalenciasCodigos", _c("CodINOS nvarchar(20), CodNBU nvarchar(20), CodNBU2012 nvarchar(20)")),
        Table("Determinaciones", _c("CodDeterminacion nvarchar(10), Nombre nvarchar(255), Unidad nvarchar(20), "
                                    "RangoReferencia nvarchar(255), CodPractica nvarchar(20)"), "CodDeterminacion"),
        Table("ResultadoItem", _c("IdItem int+, IdProtocolo int, CodDeterminacion nvarchar(10), Valor nvarchar(50), "
                                  "Unidad nvarchar(20), RangoReferencia nvarchar(255), Equipo nvarchar(50), "
                                  "FechaCarga datetime"),
              "IdItem", foreign_keys=[("IdProtocolo", "Protocolos", "IdProtocolo")]),
        Table("ObrasSociales", _c("IdObraSocial int+, Sigla nvarchar(20), Nombre nvarchar(255), CUIT nvarchar(13), "
                                  "Activa bit"), "IdObraSocial"),
        Table("Medicos", _c("IdMedico int+, Nombre nvarchar(255), Matricula nvarchar(20), Especialidad nvarchar(100), "
                            "Telefono nvarchar(100)"), "IdMedico", encoding="latin-1"),
        Table("Sedes", _c("CodSede nvarchar(1), Nombre nvarchar(100), Direccion nvarchar(255), FechaApertura datetime"),
              "CodSede"),
        Table("Precios", _c("Id int+, CodPractica nvarchar(20), IdObraSocial int, Valor money, VigenciaDesde datetime"),
              "Id"),
        Table("Recibos", _c("IdRecibo int+, Fecha datetime, Nombre nvarchar(255), Concepto nvarchar(255), "
                            "Importe nvarchar(50)"), "IdRecibo"),
        Table("Deudores", _c("id int+, IdRecibo int, Fecha datetime, Nombre nvarchar(255), Concepto nvarchar(255), "
                             "Importe nvarchar(50), Saldo nvarchar(50)"), "id"),
        Table("ParaLlamar", _c("ID int+, Fecha datetime, Nombre nvarchar(255), Telefono nvarchar(255), "
                               "IdProtocolo int, Llamado bit, LlamadoDos bit"), "ID"),
        Table("UltimoNumero", _c("PuntoVenta int, TipoComprobante nvarchar(2), Ultimo int")),
        Table("Comprobantes", _c("IdComprobante int+, PuntoVenta int, TipoComprobante nvarchar(2), Numero int, "
                                 "Fecha datetime, IdProtocolo int, IdPaciente int, Importe money, CAE nvarchar(14)"),
              "IdComprobante", foreign_keys=[("IdProtocolo", "Protocolos", "IdProtocolo")]),
        Table("ComprobantesRechazados", _c("Id int+, Fecha datetime, PuntoVenta int, TipoComprobante nvarchar(2), "
                                           "Numero int, Codigo nvarchar(10), Mensaje nvarchar(255)"), "Id"),
        Table("Usuarios", _c("Usuario nvarchar(50), Nombre nvarchar(255), Sector nvarchar(50), Clave nvarchar(50)"),
              "Usuario"),
        Table("MIG_LIS_PACIENTES", _c("LIS_ID int, APELLIDO nvarchar(100), NOMBRE nvarchar(100), "
                                      "DOCUMENTO nvarchar(50), FECHA_NAC nvarchar(10), ORIGEN_ID int")),
        Table("Configuracion", _c("Clave nvarchar(50), Valor nvarchar(255)")),
        Table("Feriados", _c("Fecha datetime, Descripcion nvarchar(100)")),
    ]
    return t


WIDE_COLUMNS_OTHERS = {
    "Orina": ["Color", "Aspecto", "Densidad", "pH", "Proteinas", "Glucosa", "Sedimento"],
    "Serologia": ["Prueba", "Resultado", "Titulo"],
    "Proteinograma": ["ProtTotales", "Albumina", "Alfa1", "Alfa2", "Beta", "Gamma"],
    "Espermograma": ["Volumen", "Concentracion", "Movilidad", "Morfologia"],
    "EstadoAcidoBase": ["pH", "pCO2", "pO2", "HCO3", "EB"],
    "Urocultivo": ["Germen", "Recuento", "Antibiograma"],
    "GrupoFactor": ["Grupo", "Factor"],
}
# Los 23 sin clave que el asistente de 2011 dejó de solo lectura recibieron una columna IDENTITY a
# las apuradas; en tres tablas quedó como id, ID e Id (Deudores, ParaLlamar, ProtocoloPracticas).
# Entre las anchas, las que la recibieron se llaman Id.
WIDE_WITH_IDENTITY = 20


def _wide() -> list[Table]:
    out = []
    names = list(WIDE_FROM_PRACTICE) + WIDE_OTHERS
    for i, name in enumerate(names):
        params = WIDE_FROM_PRACTICE[name][1] if name in WIDE_FROM_PRACTICE else \
            WIDE_COLUMNS_OTHERS.get(name, ["Resultado", "Valor", "Metodo"])
        spec = ["Id int+"] if i < WIDE_WITH_IDENTITY else []
        spec += ["IdProtocolo int", "Fecha datetime"] + [f"{p} nvarchar(50)" for p in params]
        if i >= 15:                     # las de 1999 en adelante nacieron con Otro1–Otro4
            spec += [f"Otro{k} nvarchar(50)" for k in range(1, 5)]
        spec.append("Obs nvarchar(255)")
        pk = "Id" if i < WIDE_WITH_IDENTITY else ("IdProtocolo" if i < 50 else None)
        out.append(Table(name, _c(", ".join(spec)), pk, group="wide"))
    return out


def price_months() -> list[tuple[int, int]]:
    (y, m), months = FIRST_PRICE_MONTH, []
    while (y, m) <= LAST_PRICE_MONTH:
        months.append((y, m))
        y, m = (y + 1, 1) if m == 12 else (y, m + 1)
    return months


def _prices() -> list[Table]:
    cols = "CodPractica nvarchar(20), Descripcion nvarchar(255), Valor money"
    return [Table(f"Precios_{y}_{m:02d}", _c(cols), group="prices") for y, m in price_months()]


# Las tablas que nadie sabe si se usan: copias, temporales, importaciones, pegados de Excel.
UNKNOWN = {
    "Copia de Pacientes": "IdPaciente int, Nombre nvarchar(255), DNI nvarchar(50), FechaNac datetime",
    "Copia de Protocolos": "IdProtocolo int, NroProtocolo nvarchar(20), IdPaciente int, Fecha datetime",
    "Pacientes_bak_20140312": "IdPaciente int, Nombre nvarchar(255), DNI nvarchar(50), FechaNac datetime",
    "Protocolos_2010": "IdProtocolo int, NroProtocolo nvarchar(20), IdPaciente int, Fecha datetime",
    "tmpExportPortal": "NroProtocolo nvarchar(20), Paciente nvarchar(255), Fecha datetime, Hash nvarchar(32)",
    "tmpCOVID": "Fecha datetime, Paciente nvarchar(255), DNI nvarchar(50), Resultado nvarchar(50)",
    "tmpCOVID2": "Fecha datetime, Paciente nvarchar(255), DNI nvarchar(50), Resultado nvarchar(50)",
    "Errores de pegado": "Campo0 nvarchar(255), Campo1 nvarchar(255), Campo2 nvarchar(255)",
    "Errores de importación": "Error nvarchar(255), Campo nvarchar(255), Fila int",
    "Hoja1$": "F1 nvarchar(255), F2 nvarchar(255), F3 nvarchar(255), F4 nvarchar(255)",
    "Hoja2$": "F1 nvarchar(255), F2 nvarchar(255)",
    "Tabla1": "Campo1 nvarchar(255), Campo2 nvarchar(255)",
    "Tabla2": "Campo1 nvarchar(255)",
    "zzBorrar": "Id int, Texto nvarchar(255)",
    "zzBorrarMatias": "Id int, Texto nvarchar(255), Fecha datetime",
    "ImportEquipos_tmp": "Archivo nvarchar(255), Linea nvarchar(255), Fecha datetime",
    "ImportEquipos_log": "Fecha datetime, Archivo nvarchar(255), Filas int, Error nvarchar(255)",
    "LogExportacion": "Fecha datetime, Inicio datetime, Fin datetime, Protocolos int",
    "LogErrores": "Fecha datetime, Modulo nvarchar(50), Error nvarchar(255)",
    "AuditoriaVieja": "Fecha datetime, Usuario nvarchar(50), Tabla nvarchar(50), Accion nvarchar(20)",
    "Pacientes_Duplicados_Revisar": "IdPaciente int, IdPacienteDuplicado int, Revisado bit",
    "Pacientes_Fusionar": "IdPaciente int, IdDestino int",
    "ObrasSocialesViejas": "Sigla nvarchar(20), Nombre nvarchar(255)",
    "PreciosNuevos": "CodPractica nvarchar(20), Valor money",
    "PreciosCopia2025": "CodPractica nvarchar(20), IdObraSocial int, Valor money, VigenciaDesde datetime",
    "NBU_import": "Codigo nvarchar(20), Descripcion nvarchar(255), UB nvarchar(20)",
    "NBU2012_import": "Codigo nvarchar(20), Descripcion nvarchar(255), UB nvarchar(20)",
    "PadronPAMI_2019": "Afiliado nvarchar(50), Nombre nvarchar(255), Documento nvarchar(50)",
    "PadronAPROSS_2021": "Afiliado nvarchar(50), Nombre nvarchar(255), Documento nvarchar(50)",
    "Convenios_2018": "ObraSocial nvarchar(50), Practica nvarchar(20), Sede nvarchar(1)",
    "Convenios_viejo": "ObraSocial nvarchar(50), Practica nvarchar(20)",
    "Turnos_vinculo": "IdTurno int, Fecha datetime, Paciente nvarchar(255)",
    "MedicosDerivantes_import": "Nombre nvarchar(255), Matricula nvarchar(20)",
    "Feriados_2005": "Fecha datetime, Descripcion nvarchar(100)",
    "ResultadosPortal_tmp": "NroProtocolo nvarchar(20), Html nvarchar(max)",
    "ExportSIH_cola": "Id int, Mensaje nvarchar(max), Enviado bit",
    "ImportSIH_ordenes": "Id int, Mensaje nvarchar(max), Procesado bit",
    "Notificaciones_SNVS": "Fecha datetime, Paciente nvarchar(255), Evento nvarchar(100)",
    "CajaDiaria": "Fecha datetime, Sede nvarchar(1), Importe money",
    "CajaDiaria_2015": "Fecha datetime, Sede nvarchar(1), Importe money",
    "Remitos": "Numero nvarchar(20), Fecha datetime, Proveedor nvarchar(100)",
    "Insumos": "Codigo nvarchar(20), Descripcion nvarchar(255), Stock int",
    "Proveedores": "Nombre nvarchar(255), CUIT nvarchar(13), Telefono nvarchar(100)",
    "Reactivos": "Codigo nvarchar(20), Descripcion nvarchar(255), Vence datetime",
    "Equipos": "Nombre nvarchar(100), Marca nvarchar(100), Sede nvarchar(1), Puerto nvarchar(20)",
    "Consulta1_resultado": "Nombre nvarchar(255), Total int",
    "Expr1000": "Expr1000 nvarchar(255)",
}


def _unknown() -> list[Table]:
    return [Table(name, _c(spec), group="unknown") for name, spec in UNKNOWN.items()]


def all_tables() -> list[Table]:
    return _core() + _wide() + _prices() + _unknown()


TABLES = {t.name: t for t in all_tables()}
