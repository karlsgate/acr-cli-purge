#!/bin/sh

set -e

# Function to log error messages and exit
log_error_and_exit() {
  echo "Error: $1"
  exit 1
}

validate_ago() {
  local input="$1"

  # Valid units for Go durations
  local component_regex='^[0-9]+(d|h|m|s|ms|us|µs|ns)$'

  while [ -n "$input" ]; do
    if echo "$input" | grep -qE '^([0-9]+(d|h|m|s|ms|us|µs|ns))'; then
      component=$(echo "$input" | grep -oE '^[0-9]+(d|h|m|s|ms|us|µs|ns)')

      input=$(echo "$input" | sed "s/^$component//")

      if ! echo "$component" | grep -Eq "$component_regex"; then
        log_error_and_exit "Invalid duration component: $component. Please use valid Go duration format (e.g., '30m', '2h45m', '1d2h', etc.)."
      fi
    else
      log_error_and_exit "Invalid duration format: $input. Please use valid Go duration format."
    fi
  done
}

# Validate required inputs
[ -z "${INPUT_REGISTRY}" ] && log_error_and_exit "Registry input is required"
[ -z "${INPUT_USERNAME}" ] && log_error_and_exit "Username input is required"
[ -z "${INPUT_PASSWORD}" ] && log_error_and_exit "Password input is required"

# Set optional inputs with defaults
REPO="${INPUT_REPO:-all}"
TAG_REGEX="${INPUT_TAG_REGEX:-.*}"
REPO_REGEX="${INPUT_REPO_REGEX:-.*}"
AGO="${INPUT_AGO:-30d}"
KEEP="${INPUT_KEEP:-3}"
DRY_RUN="${INPUT_DRY_RUN:-false}"
DELETE_UNTAGGED="${INPUT_DELETE_UNTAGGED:-false}"

# Validate the AGO input
validate_ago "$AGO"

# Determine whether to use REPO or REPO_REGEX
if [ -n "$REPO" ]; then
  FILTER="$REPO:$TAG_REGEX"
else
  FILTER="$REPO_REGEX:$TAG_REGEX"
fi

# Log in to the Azure Container Registry
echo "Logging in to Azure Container Registry: $INPUT_REGISTRY"
if ! echo $INPUT_PASSWORD | acr login --username "$INPUT_USERNAME" --password-stdin "$INPUT_REGISTRY"; then
  log_error_and_exit "Failed to log in to Azure Container Registry"
fi

# Run the acr-cli command with error handling
echo "Starting ACR cleanup for registry ${INPUT_REGISTRY}..."

OUTPUT=$(acr purge -r "$INPUT_REGISTRY" \
    --ago "$AGO" \
    --keep "$KEEP" \
    --filter "$FILTER" \
    $( [ "$DRY_RUN" = true ] && echo "--dry-run" ) \
    $( [ "$DELETE_UNTAGGED" = true ] && echo "--untagged" ))

if [ $? -ne 0 ]; then
  log_error_and_exit "Failed to execute ACR cleanup"
fi

echo "$OUTPUT"

echo "## 📄🧹 ACR Cleanup Summary for $INPUT_REGISTRY" >> $GITHUB_STEP_SUMMARY
TAGS_DELETED=$(echo "$OUTPUT" | grep -E 'Number of (tags to be deleted|deleted tags):')
MANIFESTS_DELETED=$(echo "$OUTPUT" | grep -E 'Number of (manifests to be deleted|deleted manifests):')

echo "$TAGS_DELETED" >> $GITHUB_STEP_SUMMARY
echo "$MANIFESTS_DELETED" >> $GITHUB_STEP_SUMMARY

echo "ACR cleanup completed successfully."
