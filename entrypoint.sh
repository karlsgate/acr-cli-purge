#!/bin/sh

set -e

# Function to log error messages and exit
log_error_and_exit() {
  echo "Error: $1"
  exit 1
}

# Validate required inputs
[ -z "${INPUT_REGISTRY}" ] && log_error_and_exit "Registry input is required"
[ -z "${INPUT_USERNAME}" ] && log_error_and_exit "Username input is required"
[ -z "${INPUT_PASSWORD}" ] && log_error_and_exit "Password input is required"

# Set optional inputs with defaults
REPO="${INPUT_REPO:-all}"
TAG_REGEX="${INPUT_TAG_REGEX:-.*}"
REPO_REGEX="${INPUT_REPO_REGEX:-.*}"
DAYS_TO_KEEP="${INPUT_DAYS_TO_KEEP:-30}"
KEEP="${INPUT_KEEP:-3}"
DRY_RUN="${INPUT_DRY_RUN:-false}"
DELETE_UNTAGGED="${INPUT_DELETE_UNTAGGED:-false}"

# Log in to the Azure Container Registry
echo "Logging in to Azure Container Registry: $INPUT_REGISTRY"
if ! echo $INPUT_PASSWORD | acr login --username "$INPUT_USERNAME" --password-stdin "$INPUT_REGISTRY"; then
  log_error_and_exit "Failed to log in to Azure Container Registry"
fi

# Run the acr-cli command with error handling
echo "Starting ACR cleanup for registry ${INPUT_REGISTRY}..."

if ! acr purge -r "$INPUT_REGISTRY" \
    --ago "${DAYS_TO_KEEP}d" \
    --keep "$KEEP" \
    --filter "${REPO_REGEX}:${TAG_REGEX}" \
    $( [ "$DRY_RUN" = true ] && echo "--dry-run" ) \
    $( [ "$DELETE_UNTAGGED" = true ] && echo "--delete-untagged" ); then
  log_error_and_exit "Failed to execute ACR cleanup"
fi

echo "ACR cleanup completed successfully."
