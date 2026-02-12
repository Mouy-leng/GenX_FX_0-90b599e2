Summary of setup for blurts-server:
- Cloned the repository.
- Installed node and python dependencies.
- Configured .env.local with dummy secrets.
- Generated telemetry (Glean) and experiments (Nimbus) files.
- Verified with npm test (380+ tests passed).
- Created a Render Postgres instance for the user: https://dashboard.render.com/d/dpg-d670qvg6fj8s7380p890-a
- Note: Docker services could not be started in the current environment due to pull rate limits and filesystem issues.
