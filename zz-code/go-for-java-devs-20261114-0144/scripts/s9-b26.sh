#!/usr/bin/env bash
# B-26 / F11 rompe a propósito: $push sin límite contra un documento, hasta 200.000 puntos.
. /scripts/prep.sh
export GOWORK=off
mkdir -p /tmp/b26 && cd /tmp/b26 && rm -f go.mod && go mod init b26 >/dev/null 2>&1 && go get go.mongodb.org/mongo-driver/v2@v2.10.0 >/dev/null 2>&1
cat > growth_test.go <<'GO'
package b26

import (
	"context"
	"testing"
	"time"

	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

func setupMongo(t *testing.T) *mongo.Collection {
	cli, err := mongo.Connect(options.Client().ApplyURI("mongodb://gfjd-mongo:27017"))
	if err != nil {
		t.Fatal(err)
	}
	c := cli.Database("zz").Collection("growth")
	_ = c.Drop(context.Background())
	return c
}

func TestDocumentGrowth(t *testing.T) {
	coll := setupMongo(t)
	ctx := context.Background()

	// Un documento por par de monedas, con TODO el histórico dentro.
	_, _ = coll.InsertOne(ctx, bson.M{"_id": "EUR/COP", "points": bson.A{}})

	for i := 0; i < 200000; i++ {
		start := time.Now()
		_, err := coll.UpdateOne(ctx,
			bson.M{"_id": "EUR/COP"},
			bson.M{"$push": bson.M{"points": bson.M{
				"day":  time.Now().AddDate(0, 0, -i),
				"rate": 4300.0 + float64(i%100),
			}}})
		elapsed := time.Since(start)

		if i%20000 == 0 || i == 199999 {
			var doc bson.Raw
			coll.FindOne(ctx, bson.M{"_id": "EUR/COP"}).Decode(&doc)
			t.Logf("puntos=%d tamaño=%d KB último push=%s",
				i, len(doc)/1024, elapsed.Round(time.Microsecond))
		}
		if err != nil {
			t.Fatalf("falló en el punto %d: %v", i, err)
		}
	}
}
GO
go mod tidy >/dev/null 2>&1; time go test -count=1 -timeout 3h -v . 2>&1 | grep -v "^=== RUN"
