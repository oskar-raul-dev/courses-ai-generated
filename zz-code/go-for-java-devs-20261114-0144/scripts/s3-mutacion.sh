#!/usr/bin/env bash
# F04 rompe a propósito: cobertura sin aserciones frente a la tabla de §6.1.
. /scripts/prep.sh
rm -rf /tmp/mut && cp -r $M/services/opsreport /tmp/mut && cd /tmp/mut/internal/workitem
mkdir -p /tmp/aparte && mv *_test.go /tmp/aparte/
cat > coverage_test.go <<'GO'
package workitem_test

import (
	"strings"
	"testing"

	"github.com/meridian/opsreport/internal/workitem"
)

func TestValidate_Coverage(t *testing.T) {
	items := []workitem.WorkItem{
		{},
		{ExternalReference: "X"},
		{ExternalReference: "X", Kind: workitem.KindImport},
		{ExternalReference: "X", Kind: workitem.KindImport, Priority: 3},
		{ExternalReference: "X", Kind: workitem.KindImport, Priority: 3,
			Description: strings.Repeat("a", 501)},
	}
	for _, item := range items {
		_ = item.Validate()
	}
}
GO
p "solo el test sin aserciones"; go1.13 test -cover . 2>&1 | tail -1
sed -i 's/if w.Priority < MinPriority || w.Priority > MaxPriority {/if w.Priority < 0 || w.Priority > MaxPriority {/' workitem.go
p "con el bug"; go1.13 test -cover . 2>&1 | tail -1
rm coverage_test.go; cp /tmp/aparte/validate_test.go .
p "tabla de §6.1 con el bug"; go1.13 test . 2>&1 | grep -E "FAIL|prioridad|ok" | head -4
