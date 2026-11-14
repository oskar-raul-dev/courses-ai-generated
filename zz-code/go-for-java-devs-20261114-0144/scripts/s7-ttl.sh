#!/usr/bin/env bash
. /scripts/prep.sh
export GOWORK=off
mkdir -p /tmp/ttl && cd /tmp/ttl && rm -f go.mod && go mod init ttl >/dev/null 2>&1 && go get github.com/valkey-io/valkey-go@v1.0.79 >/dev/null 2>&1
cat > ttl_test.go <<'GO'
package ttl

import (
	"context"
	"fmt"
	"math/rand/v2"
	"testing"
	"time"

	"github.com/valkey-io/valkey-go"
)

func ttlWithJitter(ttl time.Duration, jitter float64, r *rand.Rand) time.Duration {
	if jitter <= 0 {
		return ttl
	}
	span := float64(ttl) * jitter
	delta := (r.Float64()*2 - 1) * span
	return time.Duration(float64(ttl) + delta)
}

func TestSynchronizedExpiry(t *testing.T) {
	ctx := context.Background()
	c, err := valkey.NewClient(valkey.ClientOption{InitAddress: []string{"gfjd-valkey:6379"}})
	if err != nil {
		t.Fatal(err)
	}
	defer c.Close()
	r := rand.New(rand.NewPCG(1, 0))
	for _, jitter := range []float64{0, 0.2} {
		buckets := make([]int, 15)
		for i := 0; i < 250; i++ {
			k := fmt.Sprintf("zz:k%d", i)
			_ = c.Do(ctx, c.B().Set().Key(k).Value("v").Ex(ttlWithJitter(10*time.Second, jitter, r)).Build()).Error()
		}
		for i := 0; i < 250; i++ {
			s, _ := c.Do(ctx, c.B().Ttl().Key(fmt.Sprintf("zz:k%d", i)).Build()).AsInt64()
			if s >= 0 && int(s) < len(buckets) {
				buckets[s]++
			}
		}
		t.Logf("jitter=%.0f%% → %v", jitter*100, buckets)
	}
	p := c.Do(ctx, c.B().ConfigGet().Parameter("maxmemory-policy").Build())
	m, _ := p.AsStrMap()
	t.Logf("maxmemory-policy por defecto: %v", m)
}
GO
go mod tidy >/dev/null 2>&1; go test -count=1 -v . 2>&1 | grep -E "→|policy|FAIL|ok"
