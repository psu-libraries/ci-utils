#
# USED BY: image-release-pr  (all the new rke2/uldev deployments)
#          image-tag         (all the new rke2/uldev deployments)
#          slugify-branch
#     they all source "$(dirname "$0")/bin/ci-utils-lib.sh"
#


# source "$(dirname "$0")/bin/ci-utils-lib.sh"

# slugify_branch: Convert a branch name into a safe slug.
# - Special handling: "preview/" becomes "preview_", "update/" becomes "update_"
# - Converts to lowercase.
# - Replaces all non-alphanumeric characters with dashes.
# - Removes leading/trailing dashes and collapses multiple dashes into one.
# Usage: slugify_branch "update/some-branch@name" => "update_some-branch-name"
slugify_branch() {
  local input="${1:-}"
  if [[ -z "$input" ]]; then
    echo ""
    return
  fi

  echo "$input" \
    | sed -E 's|^preview/|preview_|;s|^update/|update_|' \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's|[^a-z0-9_]+|-|g' \
    | sed -E 's|^-+||;s|-+$||;s|-+|-|g'
}

# strip_helm_values_pipe / restore_helm_values_pipe: toggle the pipe on a
# manifest's single top-level `spec.source.helm.values` key so yq can
# traverse into it as structured YAML. Anchored to the line immediately
# following `helm:` (not to indentation, which varies across manifests, and
# not to a bare `values:` match, which previously matched nested `values:`
# keys elsewhere in the tree, e.g. route.isolatedRoutes[].paths[].values,
# and silently corrupted them into literal strings).
# Usage: strip_helm_values_pipe <manifest-file>
strip_helm_values_pipe() {
    local file="$1"
    sed -i -E '/^[[:space:]]*helm:[[:space:]]*$/{n; s/^([[:space:]]*values):[[:space:]]*\|[[:space:]]*$/\1:/}' "$file"
}

# Usage: restore_helm_values_pipe <manifest-file>
restore_helm_values_pipe() {
    local file="$1"
    sed -i -E '/^[[:space:]]*helm:[[:space:]]*$/{n; s/^([[:space:]]*values):[[:space:]]*$/\1: |/}' "$file"
}