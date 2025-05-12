CREATE TABLE nyc_taxi_yellow (
    vendor_id int COMMENT 'TPEP provider code; 1=Creative Mobile Technologies, LLC; 2=VeriFone Inc.',
    pickup_time timestamp(6) with time zone COMMENT 'Date and time when the meter was engaged',
    pickup_location_id int COMMENT 'Location ID where the meter was engaged',
    dropoff_time timestamp(6) with time zone COMMENT 'Date and time when the meter was disengaged',
    dropoff_location_id int COMMENT 'Location ID where the meter was disengaged',
    passenger_count int COMMENT 'Number of passengers in the vehicle (driver entered)',
    trip_distance double COMMENT 'Elapsed trip distance in miles reported by the meter',
    ratecode_id int COMMENT 'Final rate code in effect when the trip ended; 1=Standard Rate; 2=JFK; 3=Newark; 4=Nassau or Westchester; 5=Negotiated fare; 6=Group ride',
    payment_type int COMMENT 'How the passgener paid; 1=Credit card; 2=Cash; 3=No charge; 4=Dispute; 5=Unknown; 6=Voided trip',
    total_amount double COMMENT 'Total amount charged to passengers; cash tips not included',
    fare_amount double COMMENT 'Time-and-distance fare in USD calculated by the meter',
    tip_amount double COMMENT 'Tip amount; automatically populated for credit card tips; cash tips not included',
    tolls_amount double COMMENT 'Total amount of all tolls paid in trip',
    mta_tax double COMMENT 'MTA tax automatically triggered based on the metered rate in use; $0.50',
    improvement_surcharge double COMMENT 'Improvement surcharge assessed trips at the flag drop; $0.30',
    congestion_surcharge double COMMENT 'Congestion surcharge',
    airport_fee double COMMENT 'Airport fee',
    extra_surcharges double COMMENT 'Misc. extras and surcharges; $0.50 and $1.00 rush hour and overnight charges',
    store_and_forward_flag varchar COMMENT 'Whether the trip record was held in vehicle memory; Y(es)/N(o)')
COMMENT 'NYC Yellow Taxi trip records dataset from the NYC Taxi & Limousine Commission; https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page'
WITH (
    partitioning = ARRAY['month(pickup_time)'],
    format = 'PARQUET'
)

DESCRIBE nyc_taxi_yellow


INSERT INTO nyc_taxi_yellow
SELECT
    s.VendorID,
    s.tpep_pickup_datetime,
    s.PULocationID,
    s.tpep_dropoff_datetime,
    s.DOLocationID,
    s.passenger_count,
    s.trip_distance,
    s.RatecodeID,
    s.payment_type,
    s.total_amount,
    s.fare_amount,
    s.tip_amount,
    s.tolls_amount,
    s.mta_tax,
    s.improvement_surcharge,
    s.congestion_surcharge,
    s.airport_fee,
    s.extra,
    s.store_and_fwd_flag
FROM examples.raw_nyc_taxi_yellow s
WHERE month = '2019_02'

SELECT * FROM nyc_taxi_yellow LIMIT 10

SELECT * FROM "nyc_taxi_yellow$partitions"


/* Run a merge into to match incoming rows with the rows already in the table and instruct Trino how to handle rows that match, don't match and custom cases
/*  use Merge to deduplicate incoming rows so the writes are indempotent: if the same rows appear more than once, only one makes it into the final dataset
/* Merge works with two datasets