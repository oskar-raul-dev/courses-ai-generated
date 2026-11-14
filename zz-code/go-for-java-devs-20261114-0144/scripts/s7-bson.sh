#!/usr/bin/env bash
. /scripts/prep.sh
export GOWORK=off
cd $M/labs/bson-lab && go mod edit -go=1.25.1 && go get go.mongodb.org/mongo-driver/v2@v2.10.0 >/dev/null 2>&1
cat > zz_traps_test.go <<'GO'
package bsonlab

import (
	"context"
	"fmt"
	"testing"
	"time"

	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

type conTodo struct {
	ID     string `bson:"_id"`
	Name   string `bson:"name"`
	Legacy string `bson:"legacy"`
}
type sinLegacy struct {
	ID   string `bson:"_id"`
	Name string `bson:"name"`
}
type cero struct {
	ID         string `bson:"_id"`
	Population int64  `bson:"population,omitempty"`
	Active     bool   `bson:"active,omitempty"`
}

func TestZZTraps(t *testing.T) {
	ctx := context.Background()
	cli, err := mongo.Connect(options.Client().ApplyURI("mongodb://gfjd-mongo:27017"))
	if err != nil {
		t.Fatal(err)
	}
	c := cli.Database("zz").Collection("traps")
	_ = c.Drop(ctx)
	raw := func(id string) bson.Raw { r, _ := c.FindOne(ctx, bson.M{"_id": id}).Raw(); return r }

	// 1. sin etiquetas
	_, err = c.InsertOne(ctx, struct {
		ID         string `bson:"_id"`
		CommonName string
		UpdatedAt  time.Time
	}{"t1", "Colombia", time.Now()})
	fmt.Println("1.", err, raw("t1"))

	// 2. precisión de time.Time
	orig := time.Date(2026, 9, 11, 8, 14, 2, 123456789, time.FixedZone("COT", -5*3600))
	_, _ = c.InsertOne(ctx, bson.M{"_id": "t2", "at": orig})
	var back struct{ At time.Time `bson:"at"` }
	_ = c.FindOne(ctx, bson.M{"_id": "t2"}).Decode(&back)
	fmt.Println("2. original", orig, "→ vuelta", back.At, "Equal:", back.At.Equal(orig), "Equal truncado:", back.At.Equal(orig.Truncate(time.Millisecond)))

	// 4. omitempty
	_, _ = c.InsertOne(ctx, cero{ID: "t4", Population: 0, Active: false})
	fmt.Println("4.", raw("t4"))

	// 6. campo eliminado + Replace
	_, _ = c.InsertOne(ctx, conTodo{ID: "t6", Name: "a", Legacy: "dato viejo"})
	var s sinLegacy
	_ = c.FindOne(ctx, bson.M{"_id": "t6"}).Decode(&s)
	s.Name = "b"
	_, _ = c.ReplaceOne(ctx, bson.M{"_id": "t6"}, s)
	fmt.Println("6. tras Replace:", raw("t6"))
}
GO
go mod tidy >/dev/null 2>&1; go test -count=1 -run TestZZTraps -v . 2>&1 | grep -v "^=== RUN"; rm zz_traps_test.go
