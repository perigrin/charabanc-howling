-- Verify charabanc-howling:food-trucks on sqlite

BEGIN;

SELECT locationid,
       applicant,
       facility_type,
       address,
       status,
       schedule,
       longitude,
       latitude
  FROM food_trucks
 WHERE 0;

ROLLBACK;
