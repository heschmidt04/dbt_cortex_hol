# Doing this lab in GitHub Codespaces (VS Code)

This fork adds a [devcontainer](.devcontainer/devcontainer.json) so a fresh
Codespace comes up with **dbt Wizard**, **dbt-core + dbt-snowflake**, the dbt
VS Code extension, and a ready-made `~/.dbt/profiles.yml` — no manual installs.

> Why a devcontainer? The `curl … install-wizard.sh | sh` command installs
> dbt-wizard onto the *machine* it runs on (e.g. `/usr/local/bin` on a Mac),
> not into the git repo. A codespace is a different machine, so it needs its
> own install — the devcontainer automates that on creation.

## One-time setup (before creating the codespace)

1. Go to <https://github.com/settings/codespaces> → **Codespaces secrets** and
   add these, granting each one access to this repository
   (`heschmidt04/dbt_cortex_hol`). Use the values from your Snowflake
   connection-info sheet:

   | Secret | Example / notes |
   |---|---|
   | `SNOWFLAKE_ACCOUNT` | `ORGNAME-ACCOUNTNAME` locator |
   | `SNOWFLAKE_USER` | your HOL username |
   | `SNOWFLAKE_PASSWORD` | your HOL password |
   | `SNOWFLAKE_ROLE` | e.g. `SNOWFLAKE_INTELLIGENCE_ADMIN` |
   | `SNOWFLAKE_WAREHOUSE` | ask instructor if the sheet says "none selected" |
   | `SNOWFLAKE_DATABASE` | e.g. `USER$YOURUSERNAME` |
   | `SNOWFLAKE_SCHEMA` | e.g. `LOCAL` |

   Secrets are injected as environment variables; `~/.dbt/profiles.yml` reads
   them with `env_var()`, so **no credential is ever written to the repo**.

   > **Snowflake auth is key-pair, not password.** Accounts that enforce MFA
   > reject plain password logins, and PATs demand a network policy. So
   > `setup.sh` generates an RSA key at `~/.snowflake/rsa_key.p8` inside the
   > codespace and prints an `ALTER USER … SET RSA_PUBLIC_KEY='…'` statement —
   > run that once in a Snowsight worksheet and dbt connects with the key.
   > `SNOWFLAKE_PASSWORD` is therefore optional. The key lives only inside the
   > codespace: a new/rebuilt codespace means a new key and re-running the
   > `ALTER USER` (setup prints it again).

2. (Recommended) Fork <https://github.com/dbt-labs/snowflake_sko_hol_2026> —
   that's the actual dbt project you edit during local development (README
   section 1.2b). If your fork exists, the codespace clones it (pushable);
   otherwise it clones the upstream read-only copy.

## Create the codespace

On <https://github.com/heschmidt04/dbt_cortex_hol>: **Code → Codespaces →
Create codespace on main**. First build takes a few minutes while
`.devcontainer/setup.sh` runs. You can use it in the browser or open it in
desktop VS Code (Codespaces extension → "Open in VS Code Desktop").

## Verify the environment

```bash
dbt-wizard --version
cd /workspaces/snowflake_sko_hol_2026
dbt debug          # checks the Snowflake connection via your secrets
```

If `dbt debug` fails on a placeholder like `SET_SNOWFLAKE_ACCOUNT_SECRET`, a
secret is missing — add it, then rebuild or restart the codespace (secrets are
injected at startup).

## Launch dbt Wizard

```bash
cd /workspaces/snowflake_sko_hol_2026
dbt-wizard
```

Then follow README section **1.2b.4** to sign in with your dbt platform
workshop credentials (browser-based login + email verification + 2FA).

## Keeping your work: git workflow

- **This repo** (`/workspaces/dbt_cortex_hol`): the codespace's `origin` is
  already your fork. Plain `git add -A && git commit -m "..." && git push`
  lands on `heschmidt04/dbt_cortex_hol`. Codespaces handles GitHub auth for
  you.
- **The lab project** (`/workspaces/snowflake_sko_hol_2026`): pushable only if
  it's your fork (see one-time setup step 2). If you forked it *after* the
  codespace was created, repoint it:

  ```bash
  git -C /workspaces/snowflake_sko_hol_2026 remote set-url origin \
    https://github.com/heschmidt04/snowflake_sko_hol_2026.git
  ```

- Codespaces auto-stop after inactivity and can be **deleted after ~30 days of
  disuse** — uncommitted work dies with them. Commit and push before you walk
  away, every time.
