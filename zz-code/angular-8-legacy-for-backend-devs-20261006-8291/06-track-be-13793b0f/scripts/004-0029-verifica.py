# rescatado de la sesión 13793b0f, 2026-09-11T00:29:50Z · Verify the dump numbers are internally consistent
A,B,C,D,E = 2379,747,718,912,64
print("total", A+B+C+D+E)
print("fullName (A+B+D+E)", A+B+D+E)
print("active   (A+D+E)  ", A+D+E)
print("email    (A+B+E)  ", A+B+E)
print("contact  (D)      ", D)
print("name/_source (C)  ", C)
print("phone    (E)      ", E)
print("birthDate string  ", A+B+C+E, " date", D)
print("email ausente C+D ", C+D)
