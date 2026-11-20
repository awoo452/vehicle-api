# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/
spec/v2.0.0.html).

## [0.0.22] - 2026-11-20
PM-193 — One version-bump pull request per repo from its Dependabot branches
### Changed
- `Gemfile.lock`: `pg` 1.6.3 to 1.7.0.
- `Gemfile.lock`: `httparty` 0.24.2 to 0.24.3.
- `Gemfile.lock`: `bootsnap` 1.23.0 to 1.26.0.
- `Gemfile.lock`: `brakeman` 8.1.0 to 8.1.1. The publish gate refuses a push while Brakeman is not the latest version.
- `Gemfile`: requires Ruby 4.0.10.
- `.ruby-version`: Ruby 4.0.2 to 4.0.10.
- `Gemfile.lock`: locks Ruby 4.0.10. Brakeman refuses the publish on Ruby 4.0.2 (CVE-2026-132825).

## [0.0.21] - 2026-11-18
PM-061 — Rails 8.1.4.1 security bump in every app
### Fixed
- `Gemfile.lock`: Rails 8.1.4 to 8.1.4.1 clears Action Dispatch RemoteIp spoofing (GHSA-2gff-2mmg-m73p).
- `Gemfile.lock`: rails-html-sanitizer 1.7.2, loofah 2.25.3, and nokogiri 1.19.7, which Rails 8.1.4.1 requires.
- `Gemfile.lock`: puma 8.1.2 clears five worker hang and exhaustion advisories (GHSA-jm4r-w4xx-qxw7, GHSA-m5xw-3hrw-qcmf, GHSA-rf6g-xhmp-gm7v, GHSA-x646-wp7c-h9mg, GHSA-xw3h-pgr9-3vg7).
- `Gemfile.lock`: puma 8.1.2 clears pumactl TLS identity and cipher-filter advisories (GHSA-86xc-wrr9-xmmq, GHSA-r885-m39c-939g).
- `Gemfile.lock`: msgpack 1.8.7 clears uncapped JRuby header allocations (CVE-2026-126366).
- `Gemfile.lock`: addressable 2.9.2 clears template ReDoS, URI normalization, and misleading-host advisories.
- `Gemfile.lock`: crass 1.0.8 clears the CSS sanitizer bypass (GHSA-pq4g-8rxf-4g29).
- `Gemfile.lock`: rack 3.2.8 clears multipart memory exhaustion (GHSA-5v64-555j-wjxm).
- `Gemfile.lock`: rack 3.2.8 clears boundary and static-path bypasses (GHSA-p8x9-v4hv-2w4g, GHSA-wvg4-6p58-3gh3).
- `Gemfile.lock`: rack 3.2.8 clears invalid Host handling (GHSA-2j8w-xcrc-x985).
- `Gemfile.lock`: mcp 1.10.0 clears the OAuth discovery SSRF (GHSA-4m5j-jjfc-97gx).
- `Gemfile.lock`: rubocop 1.92.3 drops its `mcp ~> 0.6` pin, so mcp can move.
### Added
- `Gemfile.lock`: the aarch64-linux platform, for the Raspberry Pi development machines.
- `Gemfile.lock`: aarch64 nokogiri and pg binaries for that platform.
### Changed
- `.github/workflows/ci.yml`: every job runs on Ubuntu 24.04; ubuntu-latest has no Ruby 4.0.2.
- `.github/workflows/ci.yml`: every job has a time limit.
- `.github/workflows/ci.yml`: checkout v7 and cache v6.
- `.github/workflows/ci.yml`: the gem scan runs `bin/bundler-audit check --update`.
- `.github/workflows/ci.yml`: the JavaScript scan always runs its skip step; the app has no `bin/importmap`.
### Removed
- `.github/workflows/ci.yml`: the importmap audit step, which never ran without `bin/importmap`.

## [0.0.20] - 2026-09-11
### Added
- `CLAUDE.md`: points agents at the Rails Playbook, lists the rules broken most often, and says which of the playbook's `hosting/` notes apply here.
- `AGENTS.md`: sends Codex and other agents to `CLAUDE.md`.

## [0.0.19] - 2026-07-20
### Security
- Ran `bundler-audit`, which was failing in CI on `main`. Bumped: `puma` 7.2.0 → 8.0.2 (CVE-2026-47737, High — PROXY protocol v1 accepts repeated headers on persistent connections; this app had never gotten this bump since it had no dependabot config until this same day), `brakeman` 8.0.4 → 8.0.5, `rack` 3.2.5 → 3.2.6 (multipart parsing DoS/host-spoofing/directory disclosure family), `nokogiri` 1.19.2 → 1.19.4 (multiple use-after-free/out-of-bounds advisories), `rack-session` 2.1.1 → 2.1.2 (GHSA-33qg-7wpp-89cq, secretless session forgery fallback), `loofah` 2.25.1 → 2.25.2, `rails-html-sanitizer` 1.7.0 → 1.7.1 (possible XSS), `crass` 1.0.6 → 1.0.7 (four CSS-parsing DoS advisories), `mcp` 0.10.0 → 0.25.0 (five advisories: memory exhaustion, session poisoning, DNS-rebinding), `websocket-driver` 0.8.0 → 0.8.2 (four advisories), `net-imap` 0.6.3 → 0.6.4.1 (six advisories, dev-only via rubocop/brakeman toolchain), `addressable` 2.8.9 → 2.9.0 (ReDoS), `concurrent-ruby` 1.3.6 → 1.3.8, `msgpack` 1.8.0 → 1.8.3 (use-after-free), `json` 2.19.3 → 2.21.1, `erb` 6.0.2 → 6.0.6 (deserialization guard bypass). `bundler-audit check` and `brakeman` both clean afterward.

## [0.0.18] - 2026-07-20
### Added
- `.github/dependabot.yml` — this repo had no dependabot config at all, unlike its sibling APIs (pokemon-api, lego-api), which is why it showed zero open dependency PRs despite being the most out-of-date of the three (`puma` 7.2.0 vs 8.0.2 elsewhere, `brakeman` 8.0.4 vs 8.0.5). Weekly bundler + github-actions update checks, matching the other two repos exactly.

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
