--- weathersensing database
create database weathersensing;

--- create tables
--- station table
create table station (
    id bigsearial primary key,
    name text not null unique, --- same as station name in config.h
    api_key_hash text not null, --- sha256 hex of the key
    api_key_prefix text not null, ---

    --- local
    location text not null, --- human label for the station location, i.e. "rooftop in hyde park"
    latitude double precision not null, 
    longitude double precision not null,
    elevation_m double precision not null, --- height of the station above sea level (meters)
    sensor_height_m double precision not null, --- height of the sensor above the ground (meters)
    timezome text not null default 'America/Chicago', --- IANA name

    active boolean not null default true,
    created_at timestampz not null default now(),
    last_seen_at timestampz not null,

    CONSTRAINT ck_station_lat CHECK (latitude  BETWEEN -90  AND 90),
    CONSTRAINT ck_station_lon CHECK (longitude BETWEEN -180 AND 180)
)

CREATE TABLE uploads (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    station_id       BIGINT      NOT NULL REFERENCES stations(id),
    filename         TEXT        NOT NULL,
    file_start       TIMESTAMPTZ,                       -- parsed from filename, nullable
    file_end         TIMESTAMPTZ,
    received_at      TIMESTAMPTZ NOT NULL DEFAULT now(),-- server clock, not the device's
    sent_from_ip     INET,
    byte_size        INTEGER     NOT NULL,
    sha256           TEXT        NOT NULL,              -- hash of the csv payload
    rows_total       INTEGER     NOT NULL DEFAULT 0,
    rows_accepted    INTEGER     NOT NULL DEFAULT 0,
    rows_duplicate   INTEGER     NOT NULL DEFAULT 0,
    rows_rejected    INTEGER     NOT NULL DEFAULT 0,
    sensor_disconnects INTEGER   NOT NULL DEFAULT 0,    -- "SENSOR DISCONNECTED" lines
    status           TEXT        NOT NULL,              -- RECEIVED | PROCESSED | PARTIAL | FAILED
    error_message    TEXT,
    raw_csv          TEXT,                              -- optional, see retention below
    CONSTRAINT uq_upload_station_file UNIQUE (station_id, filename),
    CONSTRAINT ck_upload_status CHECK (status IN ('RECEIVED','PROCESSED','PARTIAL','FAILED'))
);
CREATE INDEX ix_uploads_station_received ON uploads (station_id, received_at DESC);

CREATE TABLE readings (
    id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    upload_id      BIGINT           NOT NULL REFERENCES uploads(id),
    station_id     BIGINT           NOT NULL REFERENCES stations(id),
    measured_at    TIMESTAMPTZ      NOT NULL,           -- device timestamp (UTC)
    temperature_c  DOUBLE PRECISION NOT NULL,
    humidity_pct   DOUBLE PRECISION NOT NULL,           -- device units (% RH)
    pressure_pa    DOUBLE PRECISION NOT NULL,           -- device units (Pa)
    CONSTRAINT uq_reading_station_time UNIQUE (station_id, measured_at)
);
CREATE INDEX ix_readings_upload ON readings (upload_id);