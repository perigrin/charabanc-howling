-- Deploy charabanc-howling:food-trucks to sqlite

BEGIN;

CREATE TABLE food_trucks (
    id INTEGER PRIMARY KEY,
    locationid INT,
    applicant TEXT,
    facility_type TEXT,
    cnn INT,
    location_description TEXT,
    address TEXT,
    blocklot INT,
    block INT,
    lot INT,
    permit TEXT,
    status TEXT,
    food_items TEXT,
    x TEXT,
    y TEXT,
    latitude TEXT,
    longitude TEXT,
    schedule TEXT,
    dayshours TEXT,
    NOISent TEXT,
    approved TEXT,
    received TEXT,
    prior_permit TEXT,
    expiration_date TEXT,
    location TEXT,
    fire_prevention_districts TEXT,
    police_districts TEXT,
    supervisor_districts TEXT,
    zip_codes TEXT,
    neighborhoods TEXT
);

COMMIT;
