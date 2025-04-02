Below is a detailed documentation of the provided `install.sh` script, organized in a meaningful sequence to reflect its logic and flow. This Bash script is designed to install or uninstall the `fw-fanctrl` package, a fan control utility for Framework laptops, along with its dependencies and systemd services. The documentation explains each section, its purpose, and how it contributes to the overall process.

---

# `install.sh` Documentation

## Overview
- **Purpose**: Installs or uninstalls the `fw-fanctrl` package, including its Python script, configuration files, `ectool` binary (for hardware interaction), and systemd services.
- **Environment**: Linux systems with `systemd`, Python 3, and `pip`.
- **Execution**: Requires root privileges (unless `--no-sudo` is used) and supports various command-line options for customization.
- **Date Context**: Assumes usage as of April 1, 2025 (per system context).

## Script Structure and Flow
The script follows a logical sequence:
1. **Shebang and Error Handling**: Sets up the interpreter and error behavior.
2. **Argument Parsing**: Processes command-line options to configure behavior.
3. **Variable Initialization**: Defines default paths and flags.
4. **Prerequisite Checks**: Validates Python and `pip` availability.
5. **Root Check**: Ensures sufficient permissions.
6. **Service Discovery**: Identifies systemd services and sub-configurations.
7. **Function Definitions**: Defines reusable functions for installation, uninstallation, and helper tasks.
8. **Main Logic**: Executes install or uninstall based on options.

---

## Detailed Breakdown

### 1. Shebang and Error Handling
```bash
#!/bin/bash
set -e
```
- **`#!/bin/bash`**: Specifies Bash as the interpreter.
- **`set -e`**: Exits the script immediately if any command fails (returns a non-zero exit code), ensuring errors don’t cascade silently.

### 2. Argument Parsing
```bash
SHORT=r,d:,p:,s:,h
LONG=remove,dest-dir:,prefix-dir:,sysconf-dir:,no-ectool,no-pre-uninstall,no-post-install,no-battery-sensors,no-sudo,no-pip-install,help
VALID_ARGS=$(getopt -a --options $SHORT --longoptions $LONG -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi
```
- **Purpose**: Parses command-line arguments using `getopt` for flexibility.
- **Options**:
  - Short: `-r` (remove), `-d` (dest-dir), `-p` (prefix-dir), `-s` (sysconf-dir), `-h` (help).
  - Long: `--remove`, `--dest-dir=<path>`, `--prefix-dir=<path>`, `--sysconf-dir=<path>`, `--no-ectool`, `--no-pre-uninstall`, `--no-post-install`, `--no-battery-sensors`, `--no-sudo`, `--no-pip-install`, `--help`.
- **Behavior**: Stores parsed arguments in `VALID_ARGS`. Exits with code 1 if parsing fails (e.g., invalid option).

### 3. Variable Initialization
```bash
TEMP_FOLDER='./.temp'
trap 'rm -rf $TEMP_FOLDER' EXIT

PREFIX_DIR="/usr"
DEST_DIR=""
SYSCONF_DIR="/etc"
SHOULD_INSTALL_ECTOOL=true
SHOULD_PRE_UNINSTALL=true
SHOULD_POST_INSTALL=true
SHOULD_REMOVE=false
NO_BATTERY_SENSOR=false
NO_SUDO=false
NO_PIP_INSTALL=false
```
- **`TEMP_FOLDER`**: Temporary directory for intermediate files (e.g., `ectool` download).
- **`trap`**: Ensures `TEMP_FOLDER` is deleted on script exit (success or failure).
- **Paths**:
  - `PREFIX_DIR`: Base installation path (default: `/usr`).
  - `DEST_DIR`: Optional prefix for staging (default: empty).
  - `SYSCONF_DIR`: System configuration directory (default: `/etc`).
- **Flags**:
  - `SHOULD_INSTALL_ECTOOL`: Install `ectool` (default: true).
  - `SHOULD_PRE_UNINSTALL`: Run `pre-uninstall.sh` (default: true).
  - `SHOULD_POST_INSTALL`: Run `post-install.sh` (default: true).
  - `SHOULD_REMOVE`: Uninstall mode (default: false).
  - `NO_BATTERY_SENSOR`: Disable battery sensors in service (default: false).
  - `NO_SUDO`: Skip sudo checks (default: false).
  - `NO_PIP_INSTALL`: Skip Python package installation via `pip` (default: false).

### 4. Argument Processing Loop
```bash
eval set -- "$VALID_ARGS"
while true; do
  case "$1" in
    '--remove' | '-r') SHOULD_REMOVE=true ;;
    '--prefix-dir' | '-p') PREFIX_DIR=$2; shift ;;
    '--dest-dir' | '-d') DEST_DIR=$2; shift ;;
    '--sysconf-dir' | '-s') SYSCONF_DIR=$2; shift ;;
    '--no-ectool') SHOULD_INSTALL_ECTOOL=false ;;
    '--no-pre-uninstall') SHOULD_PRE_UNINSTALL=false ;;
    '--no-post-install') SHOULD_POST_INSTALL=false ;;
    '--no-battery-sensors') NO_BATTERY_SENSOR=true ;;
    '--no-sudo') NO_SUDO=true ;;
    '--no-pip-install') NO_PIP_INSTALL=true ;;
    '--help' | '-h') echo "Usage: $0 ..." 1>&2; exit 0 ;;
    --) break ;;
  esac
  shift
done
```
- **Purpose**: Updates variables based on parsed arguments.
- **Logic**: Loops through options, setting flags or paths. Breaks at `--` (end of options).
- **Help**: Prints usage and exits if `-h` or `--help` is provided.

### 5. Prerequisite Checks
```bash
if ! python -h 1>/dev/null 2>&1; then
    echo "Missing package 'python'!"
    exit 1
fi
if [ "$NO_PIP_INSTALL" = false ]; then
    if ! python -m pip -h 1>/dev/null 2>&1; then
        echo "Missing python package 'pip'!"
        exit 1
    fi
fi
if [ "$SHOULD_REMOVE" = false ]; then
    if ! python -m build -h 1>/dev/null 2>&1; then
        echo "Missing python package 'build'!"
        exit 1
    fi
fi
PYTHON_SCRIPT_INSTALLATION_PATH="$DEST_DIR$PREFIX_DIR/bin/fw-fanctrl"
```
- **Python**: Ensures Python 3 is installed.
- **Pip**: Checks for `pip` if `NO_PIP_INSTALL` is false.
- **Build**: Verifies the `build` module for installation (skipped in uninstall mode).
- **Path**: Sets default install path for the `fw-fanctrl` script.

### 6. Root Check
```bash
if [ "$EUID" -ne 0 ] && [ "$NO_SUDO" = false ]; then
    echo "This program requires root permissions or use the '--no-sudo' option"
    exit 1
fi
```
- **Purpose**: Ensures the script runs as root (EUID 0) unless `--no-sudo` is specified.

### 7. Service Discovery
```bash
SERVICES_DIR="./services"
SERVICE_EXTENSION=".service"
SERVICES="$(cd "$SERVICES_DIR" && find . -maxdepth 1 -type f -name "*$SERVICE_EXTENSION" -exec basename {} "$SERVICE_EXTENSION" \;)"
SERVICES_SUBCONFIGS="$(cd "$SERVICES_DIR" && find . -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)"
```
- **Purpose**: Identifies systemd service files and sub-configurations in `./services`.
- **`SERVICES`**: List of `.service` files (e.g., `fw-fanctrl`).
- **`SERVICES_SUBCONFIGS`**: Subdirectories (e.g., `system-sleep` for sleep-related configs).

### 8. Helper Functions

#### `sanitizePath`
```bash
function sanitizePath() {
    local SANITIZED_PATH="$1"
    local SANITIZED_PATH=${SANITIZED_PATH//..\//}
    local SANITIZED_PATH=${SANITIZED_PATH#./}
    local SANITIZED_PATH=${SANITIZED_PATH#/}
    echo "$SANITIZED_PATH"
}
```
- **Purpose**: Cleans file paths to prevent traversal (`../`) or redundant prefixes (`./`, `/`).

#### `build`
```bash
function build() {
    echo "building package"
    rm -rf "dist/" 2> "/dev/null" || true
    python -m build -s
    find . -type d -name "*.egg-info" -exec rm -rf {} + 2> "/dev/null" || true
}
```
- **Purpose**: Builds the Python package using `python -m build -s` (source distribution), cleaning up old `dist/` and `.egg-info` directories.

#### `uninstall_legacy`
```bash
function uninstall_legacy() {
    echo "removing legacy files"
    rm "/usr/local/bin/fw-fanctrl" 2> "/dev/null" || true
    rm "/usr/local/bin/ectool" 2> "/dev/null" || true
    rm "/usr/local/bin/fanctrl.py" 2> "/dev/null" || true
    rm "/etc/systemd/system/fw-fanctrl.service" 2> "/dev/null" || true
    rm "$DEST_DIR$PREFIX_DIR/bin/fw-fanctrl" 2> "/dev/null" || true
}
```
- **Purpose**: Removes old file locations from previous versions of `fw-fanctrl`.

#### `uninstall`
```bash
function uninstall() {
    if [ "$SHOULD_PRE_UNINSTALL" = true ]; then
        ./pre-uninstall.sh "$([ "$NO_SUDO" = true ] && echo "--no-sudo")"
    fi
    echo "removing services"
    for SERVICE in $SERVICES ; do
        SERVICE=$(sanitizePath "$SERVICE")
        rm -rf "$DEST_DIR$PREFIX_DIR/lib/systemd/system/$SERVICE$SERVICE_EXTENSION"
    done
    echo "removing services sub-configurations"
    for SERVICE in $SERVICES_SUBCONFIGS ; do
        SERVICE=$(sanitizePath "$SERVICE")
        echo "removing sub-configurations for [$SERVICE]"
        SUBCONFIGS="$(cd "$SERVICES_DIR/$SERVICE" && find . -mindepth 1 -type f)"
        for SUBCONFIG in $SUBCONFIGS ; do
            SUBCONFIG=$(sanitizePath "$SUBCONFIG")
            echo "removing '$DEST_DIR$PREFIX_DIR/lib/systemd/$SERVICE/$SUBCONFIG'"
            rm -rf "$DEST_DIR$PREFIX_DIR/lib/systemd/$SERVICE/$SUBCONFIG" 2> "/dev/null" || true
        done
    done
    if [ "$NO_PIP_INSTALL" = false ]; then
        echo "uninstalling python package"
        python -m pip uninstall -y fw-fanctrl 2> "/dev/null" || true
    fi
    ectool autofanctrl 2> "/dev/null" || true
    if [ "$SHOULD_INSTALL_ECTOOL" = true ]; then
        rm "$DEST_DIR$PREFIX_DIR/bin/ectool" 2> "/dev/null" || true
    fi
    rm -rf "$DEST_DIR$SYSCONF_DIR/fw-fanctrl" 2> "/dev/null" || true
    rm -rf "/run/fw-fanctrl" 2> "/dev/null" || true
    uninstall_legacy
}
```
- **Purpose**: Uninstalls `fw-fanctrl`.
- **Steps**:
  1. Runs `pre-uninstall.sh` if enabled.
  2. Removes service files from `$PREFIX_DIR/lib/systemd/system`.
  3. Deletes sub-configurations (e.g., `system-sleep` hooks).
  4. Uninstalls the Python package via `pip` (if installed that way).
  5. Restores default fan control with `ectool autofanctrl`.
  6. Removes `ectool`, config directory, runtime data, and legacy files.

#### `install`
```bash
function install() {
    uninstall_legacy
    rm -rf "$TEMP_FOLDER"
    mkdir -p "$DEST_DIR$PREFIX_DIR/bin"
    if [ "$SHOULD_INSTALL_ECTOOL" = true ]; then
        mkdir "$TEMP_FOLDER"
        installEctool "$TEMP_FOLDER" || (echo "an error occurred..." && exit 1)
        rm -rf "$TEMP_FOLDER"
    fi
    mkdir -p "$DEST_DIR$SYSCONF_DIR/fw-fanctrl"
    build
    if [ "$NO_PIP_INSTALL" = false ]; then
        echo "installing python package"
        python -m pip install --prefix="$DEST_DIR$PREFIX_DIR" dist/*.tar.gz
        actual_installation_path="$(which 'fw-fanctrl' 2>/dev/null)"
        if [[ $? -eq 0 ]]; then
            PYTHON_SCRIPT_INSTALLATION_PATH="$actual_installation_path"
        fi
        rm -rf "dist/" 2> "/dev/null" || true
    fi
    echo "script installation path is '$PYTHON_SCRIPT_INSTALLATION_PATH'"
    cp -pn "./src/fw_fanctrl/_resources/config.json" "$DEST_DIR$SYSCONF_DIR/fw-fanctrl" 2> "/dev/null" || true
    cp -f "./src/fw_fanctrl/_resources/config.schema.json" "$DEST_DIR$SYSCONF_DIR/fw-fanctrl" 2> "/dev/null" || true
    if [ "$NO_BATTERY_SENSOR" = true ]; then
        NO_BATTERY_SENSOR_OPTION="--no-battery-sensors"
    fi
    echo "creating '$DEST_DIR$PREFIX_DIR/lib/systemd/system'"
    mkdir -p "$DEST_DIR$PREFIX_DIR/lib/systemd/system"
    echo "creating services"
    for SERVICE in $SERVICES ; do
        SERVICE=$(sanitizePath "$SERVICE")
        if [ "$SHOULD_PRE_UNINSTALL" = true ] && [ "$(systemctl is-active "$SERVICE")" == "active" ]; then
            echo "stopping [$SERVICE]"
            systemctl stop "$SERVICE"
        fi
        echo "creating '$DEST_DIR$PREFIX_DIR/lib/systemd/system/$SERVICE$SERVICE_EXTENSION'"
        cat "$SERVICES_DIR/$SERVICE$SERVICE_EXTENSION" | sed -e "s/%PYTHON_SCRIPT_INSTALLATION_PATH%/${PYTHON_SCRIPT_INSTALLATION_PATH//\//\\/}/" | sed -e "s/%SYSCONF_DIRECTORY%/${SYSCONF_DIR//\//\\/}/" | sed -e "s/%NO_BATTERY_SENSOR_OPTION%/${NO_BATTERY_SENSOR_OPTION}/" | tee "$DEST_DIR$PREFIX_DIR/lib/systemd/system/$SERVICE$SERVICE_EXTENSION" > "/dev/null"
    done
    echo "adding services sub-configurations"
    for SERVICE in $SERVICES_SUBCONFIGS ; do
        SERVICE=$(sanitizePath "$SERVICE")
        echo "adding sub-configurations for [$SERVICE]"
        SUBCONFIG_FOLDERS="$(cd "$SERVICES_DIR/$SERVICE" && find . -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)"
        mkdir -p "$DEST_DIR$PREFIX_DIR/lib/systemd/$SERVICE"
        for SUBCONFIG_FOLDER in $SUBCONFIG_FOLDERS ; do
            SUBCONFIG_FOLDER=$(sanitizePath "$SUBCONFIG_FOLDER")
            echo "creating '$DEST_DIR$PREFIX_DIR/lib/systemd/$SERVICE/$SUBCONFIG_FOLDER'"
            mkdir -p "$DEST_DIR$PREFIX_DIR/lib/systemd/$SERVICE/$SUBCONFIG_FOLDER"
        done
        SUBCONFIGS="$(cd "$SERVICES_DIR/$SERVICE" && find . -mindepth 1 -type f)"
        for SUBCONFIG in $SUBCONFIGS ; do
            SUBCONFIG=$(sanitizePath "$SUBCONFIG")
            echo "adding '$DEST_DIR$PREFIX_DIR/lib/systemd/$SERVICE/$SUBCONFIG'"
            cat "$SERVICES_DIR/$SERVICE/$SUBCONFIG" | sed -e "s/%PYTHON_SCRIPT_INSTALLATION_PATH%/${PYTHON_SCRIPT_INSTALLATION_PATH//\//\\/}/" | tee "$DEST_DIR$PREFIX_DIR/lib/systemd/$SERVICE/$SUBCONFIG" > "/dev/null"
            chmod +x "$DEST_DIR$PREFIX_DIR/lib/systemd/$SERVICE/$SUBCONFIG"
        done
    done
    if [ "$SHOULD_POST_INSTALL" = true ]; then
        ./post-install.sh --dest-dir "$DEST_DIR" --sysconf-dir "$SYSCONF_DIR" "$([ "$NO_SUDO" = true ] && echo "--no-sudo")"
    fi
}
```
- **Purpose**: Installs `fw-fanctrl`.
- **Steps**:
  1. Removes legacy files.
  2. Sets up directories and installs `ectool` if enabled.
  3. Builds and installs the Python package via `pip` (unless skipped).
  4. Copies configuration files.
  5. Creates and configures systemd service files, stopping active services if needed.
  6. Adds sub-configurations (e.g., sleep hooks).
  7. Runs `post-install.sh` if enabled.

#### `installEctool`
```bash
function installEctool() {
    workingDirectory=$1
    echo "installing ectool"
    ectoolDestPath="$DEST_DIR$PREFIX_DIR/bin/ectool"
    ectoolJobId="$(cat './fetch/ectool/linux/gitlab_job_id')"
    ectoolSha256Hash="$(cat './fetch/ectool/linux/hash.sha256')"
    artifactsZipFile="$workingDirectory/artifact.zip"
    curl -s -S -o "$artifactsZipFile" -L "https://gitlab.howett.net/DHowett/ectool/-/jobs/${ectoolJobId}/artifacts/download?file_type=archive" || (echo "failed to download..." && return 1)
    actualEctoolSha256Hash=$(sha256sum "$artifactsZipFile" | cut -d ' ' -f 1)
    if [[ "$actualEctoolSha256Hash" != "$ectoolSha256Hash" ]]; then
        echo "Incorrect sha256 sum..."
        return 1
    fi
    unzip -q -j "$artifactsZipFile" '_build/src/ectool' -d "$workingDirectory" &&
    cp "$workingDirectory/ectool" "$ectoolDestPath" &&
    chmod +x "$ectoolDestPath" || (echo "failed to extract..." && return 1)
    echo "ectool installed"
}
```
- **Purpose**: Downloads and installs `ectool` from a GitLab artifact, verifying its integrity.

### 9. Main Logic
```bash
if [ "$SHOULD_REMOVE" = true ]; then
    uninstall
else
    install
fi
exit 0
```
- **Purpose**: Executes `uninstall` if `--remove` is set, otherwise runs `install`.
- **Exit**: Returns 0 (success) unless an error occurs earlier (due to `set -e`).

---

## Usage Examples
- **Install**: `sudo ./install.sh`
- **Uninstall**: `sudo ./install.sh --remove`
- **Custom Path**: `sudo ./install.sh --prefix-dir=/opt`
- **No `ectool`**: `sudo ./install.sh --no-ectool`

## Notes
- **Error Handling**: Robust with `set -e` and silent failures (`|| true`).
- **Flexibility**: Supports staging installs (`--dest-dir`) and skipping steps (e.g., `--no-pip-install`).
- **Dependencies**: Requires `curl`, `unzip`, Python 3, `pip`, and `build`.

This documentation should provide a clear, sequential understanding of `install.sh`. Let me know if you need further clarification!