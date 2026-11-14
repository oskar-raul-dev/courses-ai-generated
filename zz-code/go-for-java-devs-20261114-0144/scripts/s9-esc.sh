#!/usr/bin/env bash
. /scripts/prep.sh
export GOWORK=off
cd $M/labs/escape-lab && go mod edit -go=1.25.1
cat > zz_tipos.go <<'GO'
package escapelab

import "strconv"

// Completado en zz-code.
type Entry struct{ ID int }
type Row struct{ ID int }

func (r Row) String() string { return strconv.Itoa(r.ID) }
GO
goimports -w escape.go
go build -gcflags='-m' . 2>&1 | grep -v "inlin" | head -30
cat > zz_test.go <<'GO'
package escapelab

import "testing"

func BenchmarkFormatDirect(b *testing.B)  { for b.Loop() { _ = FormatDirect(123456) } }
func BenchmarkFormatSprintf(b *testing.B) { for b.Loop() { _ = FormatSprintf(123456) } }
func BenchmarkBuildGrow(b *testing.B)     { for b.Loop() { _ = BuildGrow(10000) } }
func BenchmarkBuildPresized(b *testing.B) { for b.Loop() { _ = BuildPresized(10000) } }
GO
go test -run '^$' -bench . -benchmem -count=3 . 2>&1 | grep Benchmark
