# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/
spec/v2.0.0.html).


## [0.0.1] - 2026-03-30
### Added
- Initial API for `GET /cars/random` with `persist=false` support.
- CarQuery API integration via `ExternalApi::CarService`.
- Car persistence with `vehicle_api_cars` table and request logging with `vehicle_api_request_logs`.
- Rate limiting for `GET /cars/random` via `RATE_LIMIT_PER_MINUTE`.
- Legal endpoints (`/terms`, `/privacy`, `/accessibility`) backed by `config/legal_content.json`.
- Health check endpoint at `GET /up`.

MAJOR: Incremented for incompatible API changes.
MINOR: Incremented for adding functionality in a backwards-compatible manner.
PATCH: Incremented for backwards-compatible bug fixes.

major.minor.patch
