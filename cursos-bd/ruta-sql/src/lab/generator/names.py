"""Listas fijas de las que sale todo lo que la caja escribe como texto.

Ningún dato es real: los nombres y apellidos son los más comunes de Argentina combinados al azar, y
los documentos salen de rangos plausibles, no de personas existentes.
"""

FIRST_FEMALE = [
    "MARIA", "ANA", "LAURA", "SILVIA", "NORMA", "GRACIELA", "PATRICIA", "MONICA", "SUSANA", "MARTA",
    "CLAUDIA", "ROSA", "ALICIA", "BEATRIZ", "LILIANA", "FLORENCIA", "CAMILA", "VALENTINA", "SOFIA",
    "LUCIA", "JULIETA", "MARIELA", "ELVIRA", "ESTHER", "NELIDA", "TERESA", "CARMEN", "MIRTA", "ADRIANA",
    "GABRIELA", "VERONICA", "NATALIA", "ROMINA", "AGUSTINA", "MILAGROS", "JUANA", "DORA", "OLGA",
]
FIRST_MALE = [
    "JUAN", "CARLOS", "JOSE", "LUIS", "JORGE", "PEDRO", "MIGUEL", "DANIEL", "RAUL", "HUGO", "PABLO",
    "DIEGO", "SERGIO", "MARCELO", "OSCAR", "MATIAS", "AGUSTIN", "LUCAS", "RUBEN", "HECTOR", "RICARDO",
    "ALBERTO", "EDUARDO", "FERNANDO", "GUSTAVO", "MARTIN", "NICOLAS", "FACUNDO", "SANTIAGO", "TOMAS",
    "ROBERTO", "MARIO", "ANGEL", "RAMON", "VICTOR", "ESTEBAN", "GONZALO", "EZEQUIEL",
]
LAST = [
    "GONZALEZ", "RODRIGUEZ", "GOMEZ", "FERNANDEZ", "LOPEZ", "DIAZ", "MARTINEZ", "PEREZ", "GARCIA",
    "SANCHEZ", "ROMERO", "SOSA", "ALVAREZ", "TORRES", "RUIZ", "RAMIREZ", "FLORES", "BENITEZ", "ACOSTA",
    "MEDINA", "HERRERA", "SUAREZ", "AGUIRRE", "GIMENEZ", "GUTIERREZ", "PEREYRA", "ROJAS", "MOLINA",
    "CASTRO", "ORTIZ", "SILVA", "NUÑEZ", "LUNA", "JUAREZ", "CABRERA", "RIOS", "FERREYRA", "GODOY",
    "MORALES", "PEÑA", "VERA", "CORDOBA", "MENDEZ", "MUÑOZ", "IBAÑEZ", "BUSTOS", "AGÜERO", "CEBALLOS",
    "QUIROGA", "OLMOS", "VILLARREAL", "PAEZ", "BARRIONUEVO", "CASTAÑO", "OVIEDO", "LEDESMA", "TOLEDO",
]
# Apellidos de la colectividad boliviana, peruana y paraguaya de Córdoba, para los pasaportes.
LAST_FOREIGN = ["MAMANI", "QUISPE", "CONDORI", "VARGAS", "CHOQUE", "FLORES", "HUANCA", "BENITEZ",
                "CACERES", "VILLALBA", "TICONA", "APAZA"]
# Variantes de tipeo que la recepción produce sobre el mismo apellido.
SPELLING = {"PEREZ": "PERES", "GONZALEZ": "GONZALES", "RODRIGUEZ": "RODRIGUES", "NUÑEZ": "NUNEZ",
            "MUÑOZ": "MUNOZ", "IBAÑEZ": "IBANEZ", "PEÑA": "PENA", "GIMENEZ": "JIMENEZ",
            "BENITEZ": "BENITES", "SUAREZ": "SUARES", "ALVAREZ": "ALVARES", "AGÜERO": "AGUERO",
            "CASTAÑO": "CASTANO", "PAEZ": "PAES", "VILLARREAL": "VILLAREAL"}

STREETS = ["AV. COLON", "BV. SAN JUAN", "AV. VELEZ SARSFIELD", "DEAN FUNES", "AV. RAFAEL NUÑEZ",
           "OBISPO TREJO", "AV. FUERZA AEREA", "JUAN B. JUSTO", "AV. SABATTINI", "LA RIOJA", "JUJUY",
           "AV. DONATO ALVAREZ", "SAN MARTIN", "BELGRANO", "RIVADAVIA", "AV. CIRCUNVALACION"]

# Pagadores: el código que usa el modelo nuevo y las formas en que la recepción los escribía.
PAYERS = {
    "PAMI": ["PAMI", "Pami", "P.A.M.I.", "INSSJP", "pami"],
    "APROSS": ["APROSS", "Apross", "IPAM", "A.P.R.O.S.S.", "apross"],
    "OSDE": ["OSDE", "Osde", "O.S.D.E", "osde 210", "OSDE 310"],
    "SANCOR": ["SANCOR SALUD", "Sancor", "SANCOR", "SANCOR 3000"],
    "SWISS": ["SWISS MEDICAL", "Swiss", "SMG"],
    "GALENO": ["GALENO", "Galeno"],
    "OSECAC": ["OSECAC", "Osecac", "EMPLEADOS DE COMERCIO"],
    "UOM": ["UOM", "U.O.M.", "Metalurgicos"],
    "OSPRERA": ["OSPRERA", "Osprera", "RURALES"],
    "DASPU": ["DASPU", "Daspu"],
    "PARTICULAR": ["PARTICULAR", "Particular", "PART.", "PART"],
}
PAYER_NAMES = {
    "PAMI": "Instituto Nacional de Servicios Sociales para Jubilados y Pensionados",
    "APROSS": "Administración Provincial del Seguro de Salud",
    "OSDE": "OSDE", "SANCOR": "Sancor Salud", "SWISS": "Swiss Medical", "GALENO": "Galeno",
    "OSECAC": "Obra Social de Empleados de Comercio", "UOM": "Obra Social de la Unión Obrera Metalúrgica",
    "OSPRERA": "Obra Social del Personal Rural", "DASPU": "Dirección de Asistencia Social del Personal Universitario",
    "PARTICULAR": "Particular",
}
PAYER_WEIGHTS = {"PAMI": 18, "APROSS": 22, "OSDE": 10, "SANCOR": 8, "SWISS": 4, "GALENO": 3,
                 "OSECAC": 7, "UOM": 4, "OSPRERA": 3, "DASPU": 3, "PARTICULAR": 18}

# Sedes: código de una letra (el prefijo del número de protocolo), nombre, año de apertura y peso.
SITES = [("C", "Laboratorio Central", 1996, 55), ("A", "Alta Córdoba", 2003, 12),
         ("V", "Villa Allende", 2007, 10), ("J", "Barrio Jardín", 2008, 11),
         ("R", "Cerro de las Rosas", 2009, 12)]
DRIVE_THRU = ("E", "Autohisopado (estacionamiento)", 2020)

# Determinaciones: código, nombre, unidad, mínimo y máximo plausibles, decimales, rango como texto.
ANALYTES = [
    ("GLU", "Glucemia", "mg/dL", 60, 260, 0, "70 - 110"),
    ("UREA", "Urea", "mg/dL", 12, 90, 0, "15 - 45"),
    ("CREA", "Creatinina", "mg/dL", 0.4, 2.8, 2, "0,6 - 1,2"),
    ("URIC", "Ácido úrico", "mg/dL", 2, 10, 1, "2,4 - 7"),
    ("COL", "Colesterol total", "mg/dL", 110, 320, 0, "hasta 200"),
    ("HDL", "Colesterol HDL", "mg/dL", 25, 90, 0, "mayor de 40"),
    ("LDL", "Colesterol LDL", "mg/dL", 50, 230, 0, "hasta 130"),
    ("TG", "Triglicéridos", "mg/dL", 40, 450, 0, "hasta 150"),
    ("HBA1C", "Hemoglobina glicosilada", "%", 4.2, 11, 1, "4 - 6"),
    ("HB", "Hemoglobina", "g/dL", 8, 18, 1, "Mujeres: 12-16 / Hombres: 13-17"),
    ("HTO", "Hematocrito", "%", 28, 54, 1, "Mujeres: 36-46 / Hombres: 40-52"),
    ("GR", "Glóbulos rojos", "/mm3", 3200000, 6000000, 0, "4.000.000 - 5.500.000"),
    ("GB", "Glóbulos blancos", "/mm3", 3000, 16000, 0, "Niños: 5000-15000 / Adultos: 4000-10000"),
    ("PLAQ", "Plaquetas", "/mm3", 90000, 480000, 0, "150.000 - 400.000"),
    ("VSG", "Eritrosedimentación", "mm/1h", 2, 70, 0, "hasta 20"),
    ("TSH", "TSH", "uUI/mL", 0.2, 8, 2, "0,4 - 4,5"),
    ("T4L", "T4 libre", "ng/dL", 0.6, 2.2, 2, "0,8 - 1,8"),
    ("NA", "Sodio", "mEq/L", 130, 150, 0, "135 - 145"),
    ("K", "Potasio", "mEq/L", 3.0, 6.0, 1, "3,5 - 5,1"),
    ("CL", "Cloro", "mEq/L", 95, 112, 0, "98 - 107"),
    ("GOT", "GOT (AST)", "U/L", 8, 120, 0, "hasta 40"),
    ("GPT", "GPT (ALT)", "U/L", 6, 140, 0, "hasta 41"),
    ("FAL", "Fosfatasa alcalina", "U/L", 40, 380, 0, "40 - 129"),
    ("BT", "Bilirrubina total", "mg/dL", 0.2, 2.5, 2, "hasta 1,2"),
    ("PCR", "Proteína C reactiva", "mg/L", 0.1, 60, 1, "hasta 5"),
    ("TP", "Tiempo de protrombina", "seg", 10, 25, 1, "11 - 14"),
    ("KPTT", "KPTT", "seg", 24, 50, 1, "25 - 38"),
    ("FERR", "Ferritina", "ng/mL", 8, 500, 0, "Mujeres: 13-150 / Hombres: 30-400"),
    ("B12", "Vitamina B12", "pg/mL", 150, 1200, 0, "200 - 900"),
    ("PSA", "PSA total", "ng/mL", 0.1, 12, 2, "hasta 4"),
    ("CA", "Calcio", "mg/dL", 7.8, 11, 1, "8,5 - 10,5"),
    ("MG", "Magnesio", "mg/dL", 1.4, 2.8, 1, "1,7 - 2,4"),
    ("COVPCR", "SARS-CoV-2 (PCR)", "", 0, 0, 0, "No detectable"),
]
QUALITATIVE = {"COVPCR": ["NO DETECTABLE", "NO DETECTABLE", "NO DETECTABLE", "DETECTABLE"]}

# Prácticas del nomenclador: código interno, descripción, determinaciones que produce y UB. Los
# códigos INOS y NBU son sintéticos: tienen la forma de los reales, no sus valores.
PRACTICES = [
    ("HEMOG", "Hemograma completo", ["HB", "HTO", "GR", "GB", "PLAQ"], 6),
    ("GLU", "Glucemia", ["GLU"], 2),
    ("UREA", "Uremia", ["UREA"], 2),
    ("CREA", "Creatininemia", ["CREA"], 2),
    ("URIC", "Uricemia", ["URIC"], 2),
    ("LIPID", "Lipidograma", ["COL", "HDL", "LDL", "TG"], 7),
    ("HBA1C", "Hemoglobina glicosilada", ["HBA1C"], 6),
    ("VSG", "Eritrosedimentación", ["VSG"], 2),
    ("TIROI", "Perfil tiroideo", ["TSH", "T4L"], 12),
    ("IONOG", "Ionograma", ["NA", "K", "CL"], 5),
    ("HEPAT", "Hepatograma", ["GOT", "GPT", "FAL", "BT"], 8),
    ("PCR", "Proteína C reactiva", ["PCR"], 4),
    ("COAG", "Coagulograma básico", ["TP", "KPTT"], 5),
    ("FERR", "Ferritina", ["FERR"], 7),
    ("B12", "Vitamina B12", ["B12"], 9),
    ("PSA", "Antígeno prostático específico", ["PSA"], 9),
    ("CALC", "Calcemia", ["CA"], 2),
    ("MAGN", "Magnesemia", ["MG"], 3),
    ("COVPCR", "Detección de SARS-CoV-2 por PCR", ["COVPCR"], 40),
]
PRACTICE_WEIGHTS = {"HEMOG": 26, "GLU": 22, "UREA": 12, "CREA": 14, "URIC": 6, "LIPID": 16,
                    "HBA1C": 6, "VSG": 7, "TIROI": 8, "IONOG": 7, "HEPAT": 9, "PCR": 4, "COAG": 5,
                    "FERR": 3, "B12": 2, "PSA": 3, "CALC": 2, "MAGN": 1, "COVPCR": 0}

# Las 71 tablas de examen "anchas" anteriores a 2008. Las primeras son las de las prácticas de
# arriba, con una columna por parámetro; el resto, los exámenes que Rubén fue sumando de a uno.
WIDE_FROM_PRACTICE = {
    "Hemograma": ("HEMOG", ["Hemoglobina", "Hematocrito", "GlobRojos", "GlobBlancos", "Plaquetas"]),
    "Quimica": ("GLU", ["Glucemia", "Urea", "Creatinina", "Uricemia", "Colesterol"]),
    "Lipidograma": ("LIPID", ["ColTotal", "HDL", "LDL", "Trigliceridos"]),
    "Tiroideo": ("TIROI", ["TSH", "T4Libre"]),
    "Ionograma": ("IONOG", ["Sodio", "Potasio", "Cloro"]),
    "Hepatograma": ("HEPAT", ["GOT", "GPT", "FAL", "BilTotal"]),
    "Coagulograma": ("COAG", ["TiempoProt", "KPTT"]),
    "Eritrosedimentacion": ("VSG", ["VSG1h"]),
    "HemoglobinaGlicosilada": ("HBA1C", ["HbA1c"]),
    "ProteinaCReactiva": ("PCR", ["PCR"]),
    "Ferritina": ("FERR", ["Ferritina"]),
    "VitaminaB12": ("B12", ["B12"]),
    "PSA": ("PSA", ["PSATotal"]),
    "Calcemia": ("CALC", ["Calcio"]),
    "Magnesemia": ("MAGN", ["Magnesio"]),
}
WIDE_OTHERS = [
    "Orina", "Serologia", "VDRL", "Chagas", "HIV", "HepatitisB", "HepatitisC", "Toxoplasmosis",
    "Rubeola", "BetaHCG", "LHyFSH", "Prolactina", "Cortisol", "Ferremia", "Proteinograma",
    "Inmunoglobulinas", "Complemento", "FactorReumatoideo", "ASTO", "LatexAR", "ExudadoFaringeo",
    "Urocultivo", "Coprocultivo", "Parasitologico", "SangreOculta", "Espermograma", "LCR",
    "LiquidoSinovial", "EstadoAcidoBase", "Electroforesis", "Microalbuminuria", "Clearance",
    "Fosforo", "Amilasa", "Lipasa", "CPK", "LDH", "Troponina", "Digoxinemia", "Litemia",
    "Fenitoina", "CEA", "CA125", "CA199", "AcidoFolico", "Transferrina", "GrupoFactor", "Coombs",
    "Reticulocitos", "FrotisSangre", "Fibrinogeno", "Antibiograma", "Micologico", "Baciloscopia",
    "MonoTest", "Brucelosis",
]
