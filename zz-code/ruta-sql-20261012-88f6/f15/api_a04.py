# a04 · el ejemplo de la API de Python, tal como está publicado.
from lab.race import Race
race = Race("postgres", setup=["TRUNCATE staging.specimen_take"])
race.isolation = "SERIALIZABLE"
race.step("a1", "BEGIN ISOLATION LEVEL {isolation}").step("a2", lambda conn: conn.execute("SELECT 1").fetchone())
outcomes = race.run(["a1", "a2"])          # una lista de Outcome: label, text, error, rows, value
print(outcomes[-1].value)
