# Context for Claude

This is Heidi's fork of the **dbt Labs / Snowflake Hands-On Lab** guide
(workshop: July 16, 2026, Boston). The README is the lab guide itself; the
editable dbt project used for local development is
`dbt-labs/snowflake_sko_hol_2026`, cloned to
`/workspaces/snowflake_sko_hol_2026` when running in a GitHub Codespace (see
CODESPACES.md).

## Rules

- **Never** write Snowflake or dbt-platform credentials into any tracked file.
  Credentials arrive as environment variables via Codespaces secrets
  (`SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `SNOWFLAKE_PASSWORD`,
  `SNOWFLAKE_ROLE`, `SNOWFLAKE_WAREHOUSE`, `SNOWFLAKE_DATABASE`,
  `SNOWFLAKE_SCHEMA`); `~/.dbt/profiles.yml` references them with `env_var()`.
- After making changes in a codespace, **commit and push to `origin`** (this
  fork) so nothing is lost when the codespace stops or is deleted.
- The dbt profile name expected by the lab project is `industries_snowflake`.
- dbt Wizard is installed by `.devcontainer/setup.sh` (the curl installer from
  README section 1.2b.2); if `dbt-wizard` is missing, rerun that script.
- Prefer `dbt test` over `dbt build` when models already exist (saves
  warehouse compute) — the lab makes a point of this.
