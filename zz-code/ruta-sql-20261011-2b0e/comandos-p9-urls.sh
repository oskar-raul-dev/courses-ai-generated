#!/usr/bin/env bash
# P9: status code of each source URL (no blind redirects: prints the final URL). Output: salidas/p9-urls.tsv
cd "$(dirname "$0")"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) AppleWebKit/605.1.15 Safari/605.1.15"
while read -r url; do
  [ -z "$url" ] && continue
  printf '%s\t%s\n' "$(curl -sSL -A "$UA" -o /dev/null -w '%{http_code}\t%{url_effective}' "$url")" "$url"
done <<'URLS' | tee salidas/p9-urls.tsv
https://www.oreilly.com/library/view/sql-and-relational/9781491941164/
https://sql-performance-explained.com/
https://use-the-index-luke.com/
https://pragprog.com/titles/bksap1/sql-antipatterns-volume-1/
https://www.oreilly.com/library/view/designing-data-intensive-applications/9781098119058/
https://martin.kleppmann.com/2026/03/24/designing-data-intensive-applications-2e.html
https://smsf.cs.arizona.edu/~rts/tdbbook.pdf
https://link.springer.com/book/10.1007/978-1-4842-7499-6
https://www.oracle.com/downloads/licenses/oracle-free-license.html
https://docs.oracle.com/en/database/oracle/oracle-database/23/dblic/Licensing-Information.html
https://www.microsoft.com/content/dam/microsoft/usetm/documents/sql-server/sql-server-2025-developer%2c-express%2c-evaluation/retail/SQL_Server_2025_Developer_Express_and_Evaluation_Edition_English.pdf
https://endoflife.date/mysql
URLS
