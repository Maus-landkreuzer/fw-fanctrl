
## Chapters 

1. Install
2. [Using this Software](#uts)
3. [Uninstall](#Uninstall)

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