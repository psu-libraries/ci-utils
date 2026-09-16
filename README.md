# ci-utils
A container to be used in CircleCI. Includes common utilities, such as  yq, and docker-compose. 

# Building. 
* Pushes to master build :latest 
* Tags will build a :$CIRCLE_TAG


# Utilities

## yq
- cli utility to update yaml files within CI. 
- update the ENV YQ_VERSION in the dockerfile to update


## docker 
- docker comes from the official github releases
- update the ENV DOCKERVERSION to update

## docker-compose 
- docker-compose comes from the official github releases
- update the ENV COMPOSE_VERSION to update

## Included scripts (bin/) 🔧
Below are the helper scripts packaged in `bin/` (used by CircleCI and deployment pipelines). Each entry lists purpose, common usage, and the most important environment variables.

### Overview
- These scripts are intended to be run inside CI containers and rely on typical CircleCI environment variables (e.g. `CIRCLE_TAG`, `CIRCLE_SHA1`, `CIRCLE_BRANCH`).
- The `gh` binary (GitHub CLI) is bundled so scripts can create PRs/releases without depending on the environment image.

### Script reference
- `build-and-push` — Build a Docker image and push one or more tags to the registry.
  - Key env: `REGISTRY_IMAGE`, `DOCKER_REGISTRY`, `DOCKER_LOGIN`, `DOCKER_PASSWORD`, `IMAGE_TAG`, `DOCKERFILE`, `DOCKER_CONTEXT`, `BUILD_ARGS`.
  - Behavior: logs into the registry, builds using comma-separated tags from `IMAGE_TAG`, and pushes each tag.

- `ci-utils-lib.sh` — Small shell library sourced by other scripts.
  - Exports `slugify_branch()` (branch -> safe slug) and other shared helpers.
  - Usage: `source "$(dirname "$0")/ci-utils-lib.sh"`.

- `gh` — GitHub CLI binary included for creating PRs and releases from scripts (used by `image-release-pr`, `pr-release`, etc.).

- `image-release-for-clusters` — High-level helper to tag images and open release PRs across multiple cluster manifests.
  - Usage: pass a comma-separated `clusters` list or set env `clusters`.
  - Key env: `CONFIG_REPO_NAME` / `CONFIG_REPO`, `CIRCLE_PROJECT_REPONAME`, `FROM_TAG` / `TO_TAG`.

- `image-release-pr` — Update an ArgoCD Application manifest with a new image tag and create a PR in the config repo.
  - Usage: `image-release-pr <manifest-path>` (e.g. `clusters/prod/manifests/myproj/prod.yaml`).
  - Key env: `CONFIG_REPO`, `GITHUB_USER`, `GITHUB_TOKEN`, `CIRCLE_PROJECT_REPONAME`, `TO_TAG`, `CIRCLE_SHA1`.

- `image-release-pr-singlerepo` — Single-repo variant (assets / journal-base): updates chart `values.yaml`, creates a helm release and a PR.
  - Used where chart and config live in the same repository.

- `image-tag` — Create a Harbor tag for an existing artifact (copy by digest).
  - Key env: `REGISTRY_HOST`, `HARBOR_PROJECT` (default: `library`), `REGISTRY_REPO`, `DOCKER_USERNAME`, `DOCKER_PASSWORD`, `TO_TAG`, `FROM_TAG` (optional) or `CIRCLE_BRANCH`/`CIRCLE_SHA1`.
  - Behavior: constructs a source tag (branch+SHA or provided `FROM_TAG`) and creates an immutable `TO_TAG` via Harbor API.

- `image-tag-singlerepo` — Single-repo tagging helper (assets); newer, more robust variant that can infer the source tag.

- `pr-release` — Update ArgoCD Application manifest, commit, push, and open a PR (legacy/widely used across projects).
  - Usage: `pr-release <manifest-path>`; uses `gh` to create the PR.

- `pr-release-singlerepo` — Older name / singlerepo variant (deprecated in favor of `image-release-pr-singlerepo`).

- `slugify-branch` — CLI wrapper that converts a branch name into a safe slug for tags.
  - Usage: `slugify-branch <branch-name>` (calls `slugify_branch` from `ci-utils-lib.sh`).

- `tag-image` — Tag an existing image (manifest copy) without pulling the image.
  - Key env: `REGISTRY_HOST`, `REGISTRY_REPO`, `DOCKER_USERNAME`, `DOCKER_PASSWORD`, `CIRCLE_SHA1`, `CIRCLE_TAG`.

- `tag-image-singlerepo` — Single-repo variant of `tag-image`; improved error handling and support for `FROM_TAG`.

- `trivy-check` — Run a Trivy vulnerability scan on the image; optionally triggers a rebuild via `build-and-push` when vulnerabilities are found.
  - Uses `trivy i` and will call `/usr/local/bin/build-and-push` if scan exit code indicates issues.

### Notes & tips 💡
- Most scripts expect CI-provided env vars — to run locally set the required env vars before invoking the script.
- `*-singlerepo` scripts are used where chart/config and code live together (examples: `assets`, `journal-base`).
- `pr-release-singlerepo` and `tag-image-singlerepo` are kept for compatibility but are superseded in some pipelines.

---
If you'd like, I can also add usage examples or a small quick-reference table for each script — tell me which scripts you want examples for.