-- Deploy charabanc-howling:orders to sqlite

BEGIN;

CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    person TEXT,
    drop_off TEXT,
    phone TEXT,
    truck_id INT,
    food_order TEXT,
    delivered BOOL DEFAULT FALSE,
    delivered_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMIT;
