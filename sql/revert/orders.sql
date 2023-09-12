-- Revert charabanc-howling:orders from sqlite

BEGIN;

DROP TABLE orders;

COMMIT;
