package postgres

import _ "embed"

// Completado en zz-code: delivery.go usa claimPendingSQL y la F09 da la consulta en queries.sql.
//
//go:embed queries.sql
var claimPendingSQL string
