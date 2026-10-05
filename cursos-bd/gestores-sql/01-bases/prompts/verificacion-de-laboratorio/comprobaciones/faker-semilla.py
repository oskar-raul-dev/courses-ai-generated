# P8: misma semilla y misma versión de Faker, ¿mismos datos en otra arquitectura?
import hashlib, platform, random
import faker
from faker import Faker

Faker.seed(2026)
fake = Faker(["es_MX", "es_CO", "es_CL", "es_AR"])
rows = []
for student_id in range(1, 1001):
    rows.append((student_id, fake.first_name(), fake.last_name(),
                 fake.date_of_birth(minimum_age=11, maximum_age=17).isoformat(),
                 fake.city(), fake.email()))
random.seed(2026)
scores = [round(random.uniform(1, 7), 1) for _ in range(1000)]

print("arquitectura:", platform.machine(), "· python", platform.python_version(),
      "· faker", faker.VERSION)
for r in rows[:5]:
    print(r)
digest = hashlib.sha256(repr((rows, scores)).encode()).hexdigest()
print("sha256 de 1000 alumnos + 1000 notas:", digest)
