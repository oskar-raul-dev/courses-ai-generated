-- postgres
-- La decisión sobre cada par candidato, en tres niveles. Solo el primero se fusiona sin una persona:
-- el mismo documento, la misma fecha de nacimiento y un nombre casi igual. El segundo va a la cola de
-- revisión humana; el tercero se descarta.
DROP TABLE IF EXISTS staging.match_review;
CREATE TABLE staging.match_review (
    patient_a       integer NOT NULL,
    patient_b       integer NOT NULL,
    name_similarity real NOT NULL,
    same_birth_date boolean NOT NULL,
    same_document   boolean NOT NULL,
    tier            text NOT NULL,
    decision        text,                        -- NULL mientras nadie lo revisó
    decided_by      text,
    decided_at      timestamptz,
    CONSTRAINT match_review_pkey PRIMARY KEY (patient_a, patient_b),
    CONSTRAINT match_review_tier_check CHECK (tier IN ('automatic', 'review')),
    CONSTRAINT match_review_decision_check CHECK (decision IN ('same_person', 'different_people')),
    CONSTRAINT match_review_decided_check CHECK ((decision IS NULL) = (decided_by IS NULL AND decided_at IS NULL))
);

INSERT INTO staging.match_review (patient_a, patient_b, name_similarity, same_birth_date, same_document, tier)
SELECT patient_a, patient_b, name_similarity, coalesce(same_birth_date, false), coalesce(same_document, false),
       CASE WHEN same_document AND same_birth_date AND name_similarity >= 0.8 THEN 'automatic' ELSE 'review' END
FROM staging.match_candidate
WHERE (same_document AND same_birth_date) OR name_similarity >= 0.4;
