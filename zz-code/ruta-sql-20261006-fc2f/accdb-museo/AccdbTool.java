import com.healthmarketscience.jackcess.Column;
import com.healthmarketscience.jackcess.ColumnBuilder;
import com.healthmarketscience.jackcess.DataType;
import com.healthmarketscience.jackcess.Database;
import com.healthmarketscience.jackcess.DatabaseBuilder;
import com.healthmarketscience.jackcess.IndexBuilder;
import com.healthmarketscience.jackcess.Row;
import com.healthmarketscience.jackcess.Table;
import com.healthmarketscience.jackcess.TableBuilder;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

/**
 * Builds and edits the "museum" Access file for Laboratorio Alameda, without Access or Office.
 *
 *   generate <file.accdb>              create the pacientes table with seeded dirty data
 *   export   <file.accdb> <out.csv>    dump pacientes to CSV (what Matías' "caja" would contain)
 *   apply    <file.accdb> <in.csv>     write parsed values back, as Rubén's procedure would
 */
public class AccdbTool {

    static final String TABLE = "pacientes";
    static final String[] FIELDS = {"nombre", "dni", "fecha_nac", "direccion"};

    public static void main(String[] args) throws IOException {
        if (args.length < 2) {
            System.err.println("usage: generate <accdb> | export <accdb> <csv> | apply <accdb> <csv>");
            System.exit(2);
        }
        switch (args[0]) {
            case "generate" -> generate(new File(args[1]));
            case "export" -> export(new File(args[1]), Path.of(args[2]));
            case "apply" -> apply(new File(args[1]), Path.of(args[2]));
            default -> throw new IllegalArgumentException("unknown command: " + args[0]);
        }
    }

    // ---------------------------------------------------------------- generate

    static void generate(File file) throws IOException {
        Files.deleteIfExists(file.toPath());
        try (Database db = DatabaseBuilder.create(Database.FileFormat.V2010, file)) {
            Table t = new TableBuilder(TABLE)
                    .addColumn(new ColumnBuilder("id", DataType.LONG).setAutoNumber(true))
                    .addColumn(new ColumnBuilder("nombre", DataType.TEXT).setLengthInUnits(255))
                    .addColumn(new ColumnBuilder("dni", DataType.TEXT).setLengthInUnits(50))
                    .addColumn(new ColumnBuilder("fecha_nac", DataType.TEXT).setLengthInUnits(50))
                    .addColumn(new ColumnBuilder("direccion", DataType.TEXT).setLengthInUnits(255))
                    .addIndex(new IndexBuilder(IndexBuilder.PRIMARY_KEY_NAME).addColumns("id").setPrimaryKey())
                    .toTable(db);

            List<String[]> rows = new DirtyPatients(new Random(1997)).build(120);
            for (String[] r : rows) {
                t.addRow(Column.AUTO_NUMBER, nullIfEmpty(r[0]), nullIfEmpty(r[1]),
                        nullIfEmpty(r[2]), nullIfEmpty(r[3]));
            }
            System.out.printf("created %s with %d rows in table %s%n", file, t.getRowCount(), TABLE);
        }
    }

    static Object nullIfEmpty(String s) {
        return s == null || s.isEmpty() ? null : s;
    }

    /** Seeded generator that reproduces how the front desk actually typed patients in 1997–2005. */
    static class DirtyPatients {
        final Random r;

        DirtyPatients(Random r) { this.r = r; }

        static final String[] SURNAMES = {"CASTELLANI", "RINALDI", "FERRARO", "BERTOLOTTI", "BIANCHI",
                "COLOMBO", "MARCHETTI", "DI PIETRO", "GONZALEZ", "RODRIGUEZ", "LOPEZ", "PEREZ",
                "MOYANO", "LEDESMA", "QUIROGA", "SOSA", "ROMERO", "FERREYRA", "BUSTOS", "AGUIRRE"};
        static final String[] FIRST_NAMES = {"MARIA ESTHER", "JUAN CARLOS", "NORMA", "HECTOR", "PEDRO",
                "ROSA", "SILVIA", "JORGE", "MATIAS", "FLORENCIA", "LUCIA", "CARLOS ALBERTO", "GRACIELA",
                "OSVALDO", "BEATRIZ", "SERGIO", "MIRTA", "DANIEL", "ANA MARIA", "RAUL"};
        static final String[] STREETS = {"AV COLON", "SAN MARTIN", "BV SAN JUAN", "OBISPO TREJO",
                "DEAN FUNES", "AV VELEZ SARSFIELD", "LA RIOJA", "ITUZAINGO", "25 DE MAYO", "9 DE JULIO"};

        String pick(String[] a) { return a[r.nextInt(a.length)]; }

        String name() { return pick(SURNAMES) + " " + pick(FIRST_NAMES); }

        String dni(int birthYear) {
            // Argentine DNI numbers roughly track the birth year.
            int base = Math.max(1_000_000, (birthYear - 1900) * 400_000 + r.nextInt(400_000));
            return String.valueOf(base);
        }

        String dotted(String dni) {
            StringBuilder sb = new StringBuilder(dni);
            for (int i = sb.length() - 3; i > 0; i -= 3) sb.insert(i, '.');
            return sb.toString();
        }

        String address() {
            return switch (r.nextInt(8)) {
                case 0 -> "B° ALTA CORDOBA MZA " + (1 + r.nextInt(20)) + " LOTE " + (1 + r.nextInt(30));
                case 1 -> "RUTA 20 KM " + (5 + r.nextInt(30));
                default -> pick(STREETS) + " " + (100 + r.nextInt(3900));
            };
        }

        /** dd/mm/yyyy, or the two-digit year the front desk used for anyone "old". */
        String birth(int year, boolean twoDigits) {
            int d = 1 + r.nextInt(28), m = 1 + r.nextInt(12);
            return twoDigits
                    ? String.format("%d/%02d/%02d", d, m, year % 100)
                    : String.format("%02d/%02d/%d", d, m, year);
        }

        List<String[]> build(int n) {
            List<String[]> out = new ArrayList<>();
            for (int i = 0; i < n; i++) {
                int year = 1920 + r.nextInt(86);
                String nm = name(), dni = dni(year), addr = address();
                boolean old = year < 1930;
                int kind = r.nextInt(100);
                if (kind < 40) {
                    // Clean row: each value in its own field.
                    out.add(new String[]{nm, dni, birth(year, false), addr});
                } else if (kind < 65) {
                    // Everything in nombre, following Rubén's rule on the monitor.
                    out.add(new String[]{nm + " DNI " + dni + " " + birth(year, old || r.nextBoolean()) + " " + addr,
                            "", "", ""});
                } else if (kind < 78) {
                    // DNI typed into nombre, the rest in its fields.
                    out.add(new String[]{nm + " DNI " + dni, "", birth(year, false), addr});
                } else if (kind < 83) {
                    // Dotted DNI and no "DNI" keyword.
                    out.add(new String[]{nm + " " + dotted(dni) + " " + addr, "", "", ""});
                } else if (kind < 88) {
                    // Newborn: loaded with the mother's name and DNI.
                    int by = 2000 + r.nextInt(5);
                    out.add(new String[]{"RN " + nm + " DNI " + dni + " " + birth(by, true), "", "", ""});
                } else if (kind < 91) {
                    // Foreign patient with a passport.
                    out.add(new String[]{"VARGAS MAMANI JUANA PASAP BOL " + (4_000_000 + r.nextInt(999_999))
                            + " " + birth(1988, true) + " " + addr, "", "", ""});
                } else if (kind < 95) {
                    // Phone number squeezed in after the DNI.
                    out.add(new String[]{nm + " DNI " + dni + " TEL 42" + (10000 + r.nextInt(89999)), "",
                            birth(year, false), addr});
                } else if (kind < 98) {
                    // No DNI at all, address glued to the name.
                    out.add(new String[]{nm + " " + addr, "", "", ""});
                } else {
                    // Free text in the DNI field.
                    out.add(new String[]{nm, r.nextBoolean() ? "NO TRAE" : dni + " (VER)", birth(year, false), addr});
                }
            }
            return out;
        }
    }

    // ---------------------------------------------------------------- export / apply

    static void export(File file, Path csv) throws IOException {
        try (Database db = DatabaseBuilder.open(file);
             PrintWriter w = new PrintWriter(Files.newBufferedWriter(csv, StandardCharsets.UTF_8))) {
            Table t = db.getTable(TABLE);
            w.println("id," + String.join(",", FIELDS));
            for (Row row : t) {
                StringBuilder line = new StringBuilder().append(row.getInt("id"));
                for (String f : FIELDS) line.append(',').append(quote(row.getString(f)));
                w.println(line);
            }
            System.out.printf("exported %d rows to %s%n", t.getRowCount(), csv);
        }
    }

    static String quote(String s) {
        if (s == null) return "";
        return "\"" + s.replace("\"", "\"\"") + "\"";
    }

    static void apply(File file, Path csv) throws IOException {
        Map<Integer, String[]> parsed = readCsv(csv);
        int updated = 0;
        try (Database db = DatabaseBuilder.open(file)) {
            Table t = db.getTable(TABLE);
            for (Row row : t) {
                String[] v = parsed.get(row.getInt("id"));
                if (v == null) continue;
                boolean changed = false;
                for (int i = 0; i < FIELDS.length; i++) {
                    Object newValue = nullIfEmpty(v[i]);
                    if (!java.util.Objects.equals(row.get(FIELDS[i]), newValue)) {
                        row.put(FIELDS[i], newValue);
                        changed = true;
                    }
                }
                if (changed) {
                    t.updateRow(row);
                    updated++;
                }
            }
        }
        System.out.printf("updated %d rows in %s%n", updated, file);
    }

    /** Minimal RFC 4180 reader: enough for the CSV that parse_patients.py writes. */
    static Map<Integer, String[]> readCsv(Path csv) throws IOException {
        Map<Integer, String[]> out = new HashMap<>();
        try (BufferedReader br = Files.newBufferedReader(csv, StandardCharsets.UTF_8)) {
            br.readLine(); // header
            String line;
            while ((line = br.readLine()) != null) {
                List<String> cells = new ArrayList<>();
                StringBuilder cur = new StringBuilder();
                boolean inQuotes = false;
                for (int i = 0; i < line.length(); i++) {
                    char c = line.charAt(i);
                    if (inQuotes) {
                        if (c == '"' && i + 1 < line.length() && line.charAt(i + 1) == '"') { cur.append('"'); i++; }
                        else if (c == '"') inQuotes = false;
                        else cur.append(c);
                    } else if (c == '"') inQuotes = true;
                    else if (c == ',') { cells.add(cur.toString()); cur.setLength(0); }
                    else cur.append(c);
                }
                cells.add(cur.toString());
                out.put(Integer.parseInt(cells.get(0)), cells.subList(1, 5).toArray(new String[0]));
            }
        }
        return out;
    }
}
