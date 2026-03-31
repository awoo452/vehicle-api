# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/
spec/v2.0.0.html).

## [0.0.17] - 2026-03-30
### Changed
- Removed the low-speed category because the NHTSA endpoint does not support it.

## [0.0.16] - 2026-03-30
### Changed
- Updated the low-speed vehicle type query to avoid NHTSA 404s.

## [0.0.15] - 2026-03-30
### Changed
- Included upstream metadata and request IDs in `/cars/random` error responses for easier debugging.

## [0.0.14] - 2026-03-30
### Changed
- Added a random model year to `/cars/random` responses.
- Expanded upstream error reporting for NHTSA failures, including response details in request logs.

## [0.0.13] - 2026-03-30
### Changed
- Skip importmap audit in CI when `bin/importmap` is not present (API-only app).

## [0.0.12] - 2026-03-30
### Changed
- Added RuboCop configuration and generated a TODO file for CI.
- Updated the `mcp` gem to address bundler-audit CVE warnings.

## [0.0.11] - 2026-03-30
### Added
- GitHub Actions CI pipeline to run linting, security scans, and tests.

## [0.0.10] - 2026-03-30
### Added
- Baseline tests for cars controller, legal pages, health check, and vehicle model behavior.
- Tightened vehicle type queries for category filtering to reduce passenger misclassification and 404s.

## [0.0.9] - 2026-03-30
### Changed
- Fetch makes by vehicle type before sampling models to reduce empty or invalid results.
- Filtered out models that exactly match the make name.

## [0.0.8] - 2026-03-30
### Changed
- Added vehicle category filtering for `/cars/random` using NHTSA vehicle types.

## [0.0.7] - 2026-03-30
### Changed
- Fetch NHTSA models by make ID to avoid 404s on makes with special characters.

## [0.0.6] - 2026-03-30
### Changed
- `/cars/random` now returns a random make + model from NHTSA instead of just a make.
- Normalized the response to include `make_name`, `model_name`, and a combined `name`.

## [0.0.5] - 2026-03-30
### Changed
- Switched the vehicle source to the NHTSA Vehicle API and simplified `/cars/random` responses.
- Avoided request log failures when the shared database hasn't been migrated to `vehicle_id`.

## [0.0.4] - 2026-03-30
### Changed
- Switched CarQuery requests to HTTP and added upstream error handling for `/cars/random`.

## [0.0.3] - 2026-03-30
### Changed
- Hardened CarQuery parsing to handle JSONP/unquoted keys and added a default callback param.

## [0.0.2] - 2026-03-30
### Changed
- Renamed the app to `vehicle-api` and updated database prefixes to `vehicle_api_`.
- Renamed stored tables to `vehicle_api_vehicles` and updated request logs to use `vehicle_id`.

## [0.0.1] - 2026-03-30
### Added
- Initial API for `GET /cars/random` with `persist=false` support.
- CarQuery API integration via `ExternalApi::CarService`.
- Vehicle persistence with `vehicle_api_vehicles` table and request logging with `vehicle_api_request_logs`.
- Rate limiting for `GET /cars/random` via `RATE_LIMIT_PER_MINUTE`.
- Legal endpoints (`/terms`, `/privacy`, `/accessibility`) backed by `config/legal_content.json`.
- Health check endpoint at `GET /up`.

MAJOR: Incremented for incompatible API changes.
MINOR: Incremented for adding functionality in a backwards-compatible manner.
PATCH: Incremented for backwards-compatible bug fixes.

major.minor.patch
