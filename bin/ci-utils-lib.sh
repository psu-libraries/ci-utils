source "$(dirname "$0")/bin/ci-utils-lib.sh"

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