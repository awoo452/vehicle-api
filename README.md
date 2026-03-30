# Random Vehicle Generator API

## Features

A Ruby on Rails API that fetches a random vehicle from the CarQuery API, logs each request, and can optionally store a subset of the data in PostgreSQL.

### API

`GET /cars/random` returns a random vehicle payload from the CarQuery API.

Query parameters:
- `persist=false` skips writing to the database (default persists the car).
- `fuel_type=gas|diesel|electric` filters the random vehicle by fuel type.
- `make=toyota|ford|etc` filters the random vehicle by make.
- `body=sedan|suv|coupe` filters the random vehicle by body style.
- `year=YYYY` filters the random vehicle by model year (maps to `min_year` and `max_year`).

Example:
`GET /cars/random?fuel_type=gas&make=toyota`

Side effects (when `persist` is not `false`):
- Creates or updates a `Vehicle` record with normalized fields and the full `raw_data` payload.
- Links the request log to the created vehicle via `vehicle_id`.

Request logging:
- All API requests except `GET /up` are logged in the `request_logs` table.
- Each log captures request metadata (HTTP method, path, IP address, user agent, origin, params, status, duration, metadata).

Rate limiting:
- If rate limited, returns HTTP `429` with a `Retry-After` header.

`GET /up` is the Rails health check endpoint.

### Legal Pages (HTML)

This API-only app also serves minimal HTML legal pages for compliance-friendly, stable URLs:
- `GET /terms`
- `GET /privacy`
- `GET /accessibility`

The content is stored in `config/legal_content.json` and rendered by a lightweight controller/view.

### Configuration

- `CORS_ORIGINS` — Comma-separated list of allowed origins for browser clients.
  - If unset: development/test allow localhost; production defaults to a shared allowlist.
- `DATABASE_URL` — Required in production; local development uses `config/database.yml`.
- `RATE_LIMIT_PER_MINUTE` — Max requests per minute per IP for `GET /cars/random` (default: 3).
- `RAILS_MAX_THREADS` — Connection pool size (default: 5).

### Data Model

Table: `vehicle_api_vehicles`
- `name` (string)
- `external_id` (string, unique)
- `make` (string)
- `model` (string)
- `year` (integer)
- `fuel_type` (string)
- `body` (string)
- `image_url` (string, nullable)
- `raw_data` (jsonb)
- `created_at` / `updated_at`

Table: `vehicle_api_request_logs`
- `request_id` (string)
- `http_method` (string)
- `path` (string)
- `ip` (string)
- `user_agent` (string)
- `referer` (string)
- `origin` (string)
- `params` (jsonb)
- `status` (integer)
- `duration_ms` (integer)
- `metadata` (jsonb)
- `vehicle_id` (foreign key, nullable)
- `created_at` / `updated_at`

## Setup

1. `bin/setup`

Manual setup:
- `bundle install`
- `bin/rails db:prepare`

## Run

1. `bin/rails server`

## Tests

1. `bin/rails test`
2. `bin/rails test:system`

## Changelog

See [`CHANGELOG.md`](CHANGELOG.md) for notable changes.
