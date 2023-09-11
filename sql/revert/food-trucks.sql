-- Revert charabanc-howling:food-trucks from sqlite

BEGIN;

DROP TABLE food_trucks;

COMMIT;
