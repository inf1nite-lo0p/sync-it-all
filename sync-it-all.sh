#!/bin/bash

SCRIPT_NAME="sync-it-all"

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME <directory> [OPTIONS]

Sync all Git repositories in the specified directory by pulling the latest changes from the remote.

Options:
  --with-logs              Generate a .log file with the timestamp and folder name for each sync operation.
  --help                   Show this help message and exit.

Examples:
  $SCRIPT_NAME username
    Syncs all repositories found in the 'username' directory.

  $SCRIPT_NAME .
    Syncs all repositories in the current directory.

  $SCRIPT_NAME username --with-logs
    Syncs all repositories and generates a log file in the 'username' directory.
EOF
  exit 1
}

TARGET_DIR=""
WITH_LOGS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-logs)
      WITH_LOGS=true
      shift
      ;;
    --help)
      usage
      ;;
    -*|--*)
      echo "Unknown option: $1"
      usage
      ;;
    *)
      if [[ -z "$TARGET_DIR" ]]; then
        TARGET_DIR="$1"
        shift
      else
        echo "Error: Multiple positional arguments provided: '$TARGET_DIR' and '$1'."
        usage
      fi
      ;;
  esac
done

if [[ -z "$TARGET_DIR" ]]; then
  echo "Error: Directory path is required."
  usage
fi

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: Directory '$TARGET_DIR' does not exist."
  exit 1
fi

# Resolve the absolute path and folder name of the target directory
ABS_PATH=$(realpath "$TARGET_DIR")
FOLDER_NAME=$(basename "$ABS_PATH")

cd "$ABS_PATH" || { echo "Error: Unable to navigate to directory '$ABS_PATH'."; exit 1; }

# Prepare log file if logging is enabled
if [[ "$WITH_LOGS" = true ]]; then
  TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
  LOG_FILE="$ABS_PATH/sync-log_$FOLDER_NAME_$TIMESTAMP.log"
  echo "Log file created: $LOG_FILE"
  echo "Sync operation started at $TIMESTAMP for directory: $FOLDER_NAME ($ABS_PATH)" > "$LOG_FILE"
fi

echo "Syncing all repositories in '$ABS_PATH'..."

for repo in */; do
  if [[ -d "$repo/.git" ]]; then
    echo "Syncing repository: $repo"
    {
      cd "$repo" || continue
      
      # Check if the working directory is clean
      if ! git diff --quiet || ! git diff --cached --quiet; then
        echo "Repository $repo has uncommitted changes. Stashing changes before branch checkout." | tee -a "$LOG_FILE"
        git stash push -m "sync-it-all: auto-stash before branch checkout" >> "$LOG_FILE" 2>&1
      fi

      # Attempt to check out the `main` branch, then `master`
      if git rev-parse --verify main &>/dev/null; then
        git checkout main >> "$LOG_FILE" 2>&1
      elif git rev-parse --verify master &>/dev/null; then
        git checkout master >> "$LOG_FILE" 2>&1
      else
        echo "No 'main' or 'master' branch found in $repo. Skipping..." | tee -a "$LOG_FILE"
        cd .. || exit
        continue
      fi

      # Attempt to sync the repository
      git pull --rebase
    } >> "$LOG_FILE" 2>&1 || {
      echo "Error syncing $repo. Skipping..." | tee -a "$LOG_FILE"
    }
    cd .. || exit
  else
    echo "Skipping non-repository directory: $repo" | tee -a "$LOG_FILE"
  fi
done

if [[ "$WITH_LOGS" = true ]]; then
  echo "Sync operation completed. Log file: $LOG_FILE"
else
  echo "Sync operation completed."
fi