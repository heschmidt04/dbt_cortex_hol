#!/usr/bin/env bash
# Codespace bootstrap for the dbt + Snowflake Hands-On Lab.
# Runs once when the codespace is created (postCreateCommand).
# Deliberately not `set -e`: a single failed step shouldn't brick the codespace.
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB_PROJECT_DIR="/workspaces/snowflake_sko_hol_2026"

echo "==> Installing dbt-core + dbt-snowflake"
pip install --user --quiet --upgrade pip
pip install --user --quiet dbt-core dbt-snowflake \
  || echo "WARN: dbt pip install failed — rerun: pip install --user dbt-core dbt-snowflake"

echo "==> Installing dbt Wizard CLI"
curl -fsSL https://public.staging.cdn.getdbt.com/dbt-wizard/install/install-wizard.sh | sh \
  || echo "WARN: dbt-wizard install failed — rerun the curl command from README section 1.2b.2"

echo "==> Ensuring install locations are on PATH"
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  touch "$rc"
  grep -q 'HOL_PATH_SETUP' "$rc" || cat >> "$rc" <<'EOF'
# HOL_PATH_SETUP: dbt / dbt-wizard install locations
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
EOF
done
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

echo "==> Ensuring Snowflake key pair exists (key-pair auth avoids MFA/PAT friction)"
if [ ! -f "$HOME/.snowflake/rsa_key.p8" ]; then
  mkdir -p "$HOME/.snowflake" && chmod 700 "$HOME/.snowflake"
  openssl genrsa 2048 2>/dev/null | openssl pkcs8 -topk8 -inform PEM -out "$HOME/.snowflake/rsa_key.p8" -nocrypt
  chmod 600 "$HOME/.snowflake/rsa_key.p8"
  PUBKEY=$(openssl rsa -in "$HOME/.snowflake/rsa_key.p8" -pubout 2>/dev/null | grep -v 'PUBLIC KEY' | tr -d '\n')
  echo "    NEW KEY GENERATED. Register it by running this in a Snowsight worksheet:"
  echo "    ALTER USER <your_user> SET RSA_PUBLIC_KEY='$PUBKEY';"
fi

echo "==> Writing ~/.dbt/profiles.yml (values resolved from Codespaces secrets at runtime)"
mkdir -p "$HOME/.dbt"
cp "$REPO_ROOT/.devcontainer/profiles.yml.template" "$HOME/.dbt/profiles.yml"

echo "==> Cloning the companion lab project"
if [ ! -d "$LAB_PROJECT_DIR" ]; then
  OWNER="${GITHUB_REPOSITORY%%/*}"
  # Prefer the user's fork so lab changes can be pushed; fall back to upstream.
  if [ -n "$OWNER" ] && git ls-remote "https://github.com/$OWNER/snowflake_sko_hol_2026.git" HEAD >/dev/null 2>&1; then
    git clone "https://github.com/$OWNER/snowflake_sko_hol_2026.git" "$LAB_PROJECT_DIR"
  else
    git clone https://github.com/dbt-labs/snowflake_sko_hol_2026.git "$LAB_PROJECT_DIR"
    echo "NOTE: cloned upstream dbt-labs repo (no fork found under $OWNER)."
    echo "      Fork it on GitHub to be able to push your lab changes, then:"
    echo "      git -C $LAB_PROJECT_DIR remote set-url origin https://github.com/$OWNER/snowflake_sko_hol_2026.git"
  fi
fi

echo "==> Done. Quick checks:"
command -v dbt-wizard >/dev/null && echo "    dbt-wizard: $(command -v dbt-wizard)" || echo "    dbt-wizard: NOT FOUND (see WARN above)"
command -v dbt >/dev/null && echo "    dbt:        $(command -v dbt)" || echo "    dbt:        NOT FOUND (see WARN above)"
echo "    Next steps: see CODESPACES.md at the repo root."
