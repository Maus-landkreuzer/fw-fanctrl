
## Chapters 

1. Install
2. [Using this Software](#uts)
3. [Uninstall](#Uninstall)
4. [Forbidden Knowledge](#fk)

### Install

To install run this ->

```shell
sudo ./install.sh
```

This script:
1. Installs fw-fanctrl to /usr/local/bin/.
2. Downloads and installs ectool (a tool to communicate with the Framework’s embedded controller) unless you specify otherwise.
3. Sets up a systemd service to run fw-fanctrl.
4. Copies a default configuration file to /etc/fw-fanctrl/ (or a similar system config directory).


Error you may get ->

1. Missing Python (If python3 is installed then do this)

    ```shell
    sudo apt install python-is-python3
    ```

2. Feel Free To add any future error

---
<a id="uts"></a>
### Using this Software

Use these commands

First start the systemd service to start on boot (Auto-Start)
```shell
sudo systemctl enable fw-fanctrl
```
>Wanna know what is systemcli and systemd?[click](#sd)
<a id="sd_back"></a>

Then the service immediately
```shell
sudo systemctl start fw-fanctrl
```

Check the service status to ensure it’s running:
```shell
systemctl status fw-fanctrl
```

To Stop
```shell
sudo systemctl stop fw-fanctrl
```

Disable Auto-Start (If Desired)
```shell
sudo systemctl disable fw-fanctrl
```

---

<a id="Uninstall"></a>
### Uninstall

run this command

```shell
sudo ./install.sh --remove 
```

Error

```shell
./install.sh: line 133: ./pre-uninstall.sh: cannot execute: required file not found
```

Skipping the details simply jumping on the main issue.

The main issue is this file was created on Windows (or downloaded with CRLF endings), Linux might choke on \r\n. Check and fix it:

```shell
file pre-uninstall.sh
```

If it says “with CRLF line terminators,” convert it:

```shell
sed -i 's/\r$//' pre-uninstall.sh
```

Then Try Again.

Know if fn-fanctrl is installed and where


---

### Some Extra commands 

```shell 
which fw-fanctrl
```

<a id="fk"></a>
### Forbidden Knowledge

Let’s break down the relationship between `systemctl` and `systemd`, and address your questions about whether they start automatically on boot.

<a id="sd"></a>
### What is `systemd`?
- **`systemd`** (system deamon(a background process that provides essential services)) is a system and service manager for Linux operating systems. It’s an init system (short for "initialization"), meaning it’s the first process that starts when a Linux system boots (PID 1). It then manages the startup of other processes, services, and system resources.
- Key roles of `systemd`:
  - Initializes the system (mounts filesystems, sets up networking, etc.).
  - Manages services (starts, stops, restarts them).
  - Handles logging, timers, and other system tasks.
- **Does it start on boot?**: Yes, `systemd` starts automatically when your Linux system boots. It’s baked into most modern Linux distributions (e.g., Ubuntu, Fedora, Debian, Arch) as the default init system. You don’t need to start it manually—it’s the foundation of the boot process.

### What is `systemctl`?
- **`systemctl`** (control) is a command-line tool used to interact with `systemd`. It’s not a service or process itself—it’s a utility to control and query `systemd`.
- Functions of `systemctl`:
  - Start, stop, restart, enable, or disable services (e.g., `systemctl start fw-fanctrl`).
  - Check the status of services or the system.
  - Manage system states (e.g., reboot, shutdown).
- **Does it start on boot?**: No, `systemctl` doesn’t "start" on boot because it’s not a running process—it’s a command you run manually in a terminal. However, it’s available as soon as the system boots because it’s part of the `systemd` package, which is always running.

### Relationship Between `systemctl` and `systemd`
- **Analogy**: Think of `systemd` as the engine running your Linux system, and `systemctl` as the steering wheel you use to control it.
- **Technical Link**: `systemd` is the daemon (background process) that manages services and the system state. `systemctl` sends commands to `systemd` via its API to perform actions like starting a service or checking its status.
- **Dependency**: `systemctl` relies on `systemd` being active. If `systemd` isn’t running (e.g., on a system using a different init system like SysVinit), `systemctl` won’t work.

### Answers to Your Questions
1. **What is the relation between `systemctl` and `systemd`?**
   - `systemd` is the underlying system manager that runs your system and services. `systemctl` is the user-facing tool to manage what `systemd` does.

2. **Does `systemctl` start automatically on startup (boot)?**
   - No, `systemctl` doesn’t "start" because it’s not a service—it’s a command-line tool. It’s available to use once the system boots, thanks to `systemd` running.

3. **Is this the same with `systemd` as well?**
   - No, `systemd` *does* start automatically on boot. It’s the init system, so it’s the first process that runs and stays active to manage everything else. Without `systemd` running, `systemctl` wouldn’t function.

### Practical Example (Your `fw-fanctrl` Case)
- When you run:
  ```bash
  sudo systemctl enable fw-fanctrl
  ```
  - `systemctl` tells `systemd` to configure the `fw-fanctrl.service` file so `systemd` starts it on boot.
- When you run:
  ```bash
  sudo systemctl start fw-fanctrl
  ```
  - `systemctl` instructs `systemd` to start the service now.
- `systemd` is the one actually managing the service in the background; `systemctl` is just your interface to give those instructions.

### Clarification
- If you’re asking whether the *services* controlled by `systemctl` (like `fw-fanctrl`) start on boot: Yes, if you `enable` them, `systemd` will start them automatically during boot. But `systemctl` itself is just a tool, not something that "starts."

[Go back](#sd_back)