You Might face some issues while installing or unstalling this tools. So here are some fixes ->

### Install

To install run this ->

```shell
sudo ./install.sh
```

---

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