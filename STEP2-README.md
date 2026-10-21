# Capstone 1 Step 2: Docker hardening

## Changes
- Non-root Vote (UID 10001), Result (node), Worker (.NET app UID 1654).
- Vote and Result bind port 8080 internally; exposed only to localhost on the Mac.
- Updated Result from Node 18 to Node 22 and Worker from .NET 7 to .NET 8.
- Added `.dockerignore` files; removed source bind mounts to make container builds self-contained.
- Moved PostgreSQL password into an untracked `.env` and injected it into worker/result.
- Pinned image major/minor versions; **digest pinning remains outstanding** and must be done after a tested build.

## Setup and compatibility warning
**Existing database volumes:** PostgreSQL initializes credentials only when the database volume is first created. If your Step 1 database still has password `postgres`, changing `.env` alone will not change its password. Preserve your votes by changing the existing database role password, or deliberately reset the volume if the data is disposable. Do not run `down -v` if you need the existing data.

1. `cp .env.example .env`
2. Set `POSTGRES_PASSWORD` in `.env` to a secure password. For existing Step 1 data, first rotate the existing PostgreSQL role password to match (see below).
3. `docker compose config --quiet`
4. `docker compose build --no-cache`
5. `docker compose up -d`
6. `docker compose ps`
7. Open `http://localhost:8080` and `http://localhost:8081`; cast a vote and verify the results.

To rotate the existing password while the old DB container is running, set your new password in `.env` and execute `docker compose exec db psql -U postgres -d postgres -c "ALTER USER postgres WITH PASSWORD 'YOUR_NEW_PASSWORD';"` **only if the password contains no characters that could break SQL quoting**. Prefer a safe interactive psql session (`docker compose exec db psql -U postgres`) and enter `\password postgres` when prompted. Then restart services with `docker compose up -d`.

## Verify non-root runtime
`docker compose exec vote id`
`docker compose exec result id`
`docker compose exec worker id`

## Limitations / follow-up
- Docker builds and end-to-end tests must run on your Mac; no Docker daemon is available in this authoring environment.
- Runtime upgrades and dependency compatibility need verification. NuGet dependencies are unchanged and require a vulnerability review.
- Image tags are version-constrained but not immutable. Resolve and record platform-specific image digests after testing.
- The seed profile retains its upstream Dockerfile and has not been hardened.
- The Result app has no automated functional tests in its package.json.
- The Compose `.env` is for local development; Kubernetes secrets must be handled separately.

## Final validation (October 21, 2026)

- All five Docker Compose services started successfully.
- Vote, PostgreSQL, and Redis reported healthy status.
- Vote application returned HTTP 200 on localhost:8080.
- Result application returned HTTP 200 on localhost:8081.
- End-to-end test passed: a vote was submitted and the Results page updated.
- Base images were pinned by digest.
- The production Vote image runs Gunicorn as a non-root user.
- The local .env file is excluded from Git.

## Security scan results

Trivy scanning of the production Vote image reported:
- Python dependencies: 0 HIGH or CRITICAL findings.
- Debian packages: 61 HIGH and 2 CRITICAL findings.
- Total remaining: 63 HIGH or CRITICAL findings.

The remaining vulnerabilities are documented as outstanding risks.
The image is not claimed to be vulnerability-free.

## Outstanding work

- Review and remediate remaining Debian package vulnerabilities when fixes are available.
- Independently verify Result and Worker runtime user IDs.
- Review dependencies and security findings for the Result and Worker images.
