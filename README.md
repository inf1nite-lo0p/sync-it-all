# sync-it-all

`sync-it-all` is a script for synchronizing all Git repositories in a specified directory. The script ensures all repositories are up-to-date with their remote counterparts by pulling the latest changes. It handles uncommitted changes automatically by stashing them before switching branches.

## Features

-   Synchronize all Git repositories in a directory with their remote.
-   Automatically stashes uncommitted changes to ensure clean branch checkouts.
-   Generates optional log files for detailed sync operations.

> [!IMPORTANT]
> This script requires Git to be installed and available in your system's PATH.

## Installation

1. **Download and Give Execute Permissions:**

    You can download the script directly or use `curl`:

    ```bash
    sudo curl -L -o /usr/local/bin/sync-it-all https://raw.githubusercontent.com/inf1nite-lo0p/sync-it-all/main/sync-it-all.sh
    sudo chmod +x /usr/local/bin/sync-it-all
    ```

2. **Verify Installation:**

    Check that the script is available globally:

    ```bash
    sync-it-all --help
    ```

## Usage

### Basic Usage

To synchronize all repositories in a specified directory:

```bash
sync-it-all <directory>
```

-   `<directory>`: The path to the directory containing Git repositories to synchronize.

### Example

Sync all repositories in the `example` directory:

```bash
sync-it-all example
```

Sync all repositories in the current directory:

```bash
sync-it-all .
```

### Logging

To enable logging, use the `--with-logs` flag. This creates a timestamped `.log` file in the target directory.

```bash
sync-it-all <directory> --with-logs
```

### Example

Sync all repositories in the `example` directory and generate a log file:

```bash
sync-it-all example --with-logs
```

### Log File Example

If logging is enabled, the script creates a log file with a name like `sync-log_<directory-name>_<timestamp>.log` in the target directory. The log file contains details about the synchronization process, including any errors encountered.

### How It Works

1. **Stashing Uncommitted Changes:**

    - The script stashes any uncommitted changes before switching branches to ensure the workspace is clean.

2. **Branch Checkouts:**

    - Attempts to switch to the `main` branch first. If `main` doesn't exist, it falls back to `master`.

3. **Pull Changes:**
    - Once on the correct branch, it pulls the latest changes using `git pull --rebase`.

## Options

-   `--with-logs`: Generate a `.log` file for the sync operation. Includes timestamps and repository details.
-   `--help`: Display the help message and exit.
