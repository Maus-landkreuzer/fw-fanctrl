## Index

### Learning basics
1. [if else in shell scripting](#ifelse)
2. [getopt](#getopt)



<a id="ifelse"></a>
### If-else-cases

First run this 
#### Example 1->

```shell
#!/bin/bash

name="Alice"
age=30
file="my_document.txt"

if [ "$name" = "Bob" ]; then
  echo "Hello, Bob!"
elif [ "$age" -gt 25 ] && [ -f "$file" ]; then
  echo "Alice is older than 25 and $file exists."
else
  echo "Neither condition was met."
fi

if [ -d "my_directory" ]; then
  echo "The directory 'my_directory' exists."
else
  echo "The directory 'my_directory' does not exist."
fi

if [ -z "$name" ]; then
  echo "The name variable is empty."
else
  echo "The name is: $name"
fi
```

you might encounter this error this error:

```shell
sudo: ./learn.sh: command not found
```

run this to fix

```shell
chmod +x learn.sh
```
> In-case you wonder about [`-gt`](#-gt), [`-f`](#-f), [`-d`](#-d), [`-z`](#-z)

#### Example 2 ->

```shell
if [[ $? -ne 0 ]]; then
    exit 1;
fi
```
* `$?`: A special shell variable that holds the exit status of the most recently executed command.
  - **Exit Status**:
    - A numerical value returned by a command after execution.
    - `0`: Indicates the command was successful.
    - Non-zero (e.g., `1`): Indicates the command failed or encountered an error. The specific value depends on the error type.

#### Example 3 ->

```shell
#!/bin/bash

cat non_existent_file.txt

if [[ $? -ne 0 ]]; then
  echo "An error occurred."
  exit 1
else
  echo "No errors occurred."
fi
```
<a id="getopt"></a>
### Getopt

`getopt` is a utility used in shell scripting to parse command-line options and arguments. It helps handle both short and long options in a structured way.

#### Example ->

```bash
#!/bin/bash

# Define options
OPTIONS=hvn:
LONGOPTIONS=help,version,name:

# Parse options
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
  exit 1
fi

eval set -- "$PARSED"

# Initialize variables
name=""

# Process options
while true; do
  case "$1" in
    -h|--help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  -h, --help       Show help message"
      echo "  -v, --version    Show version"
      echo "  -n, --name       Specify a name"
      shift
      ;;
    -v|--version)
      echo "Version 1.0"
      shift
      ;;
    -n|--name)
      name="$2"
      echo "Name: $name"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Invalid option"
      exit 1
      ;;
  esac
done

# Remaining arguments
echo "Remaining arguments: $@"
```

#### Explanation:
1. **Options and Long Options**:
   - `OPTIONS`: Short options (e.g., `-h`, `-v`, `-n`).
   - `LONGOPTIONS`: Long options (e.g., `--help`, `--version`, `--name`).

2. **Parsing**:
   - `getopt` parses the options and arguments, returning a structured format.

3. **Processing**:
   - A `while` loop processes each option using a `case` statement.

4. **Special Case**:
   - `--` indicates the end of options, allowing further arguments to be processed.

#### Notes:
- `getopt` is not the same as `getopts`. `getopt` supports long options, while `getopts` does not.
- Always use `eval set -- "$PARSED"` to handle the parsed options correctly.
- The output of getopt is then usually evaluated (often using the `eval set -- ...` construct) to update the script's positional parameters, making it easy to access the option values. 

This script demonstrates how to handle both short and long options, making your shell scripts more user-friendly and versatile.

### Ultra Basics

<a id="-gt"></a>
1.`-gt`: This is a numeric comparison operator.

<a id="-f"></a>
2. `-f`: This checks if a file exists and is a regular file.

<a id="-d"></a>
3. `-d`: This checks if a directory exists.

<a id="-z"></a>
4. `-z`: This checks if a string is empty.

<a id="-ne"></a>
5. `-gt`: This is a numeric comparison operator.

<a id="-f"></a>
2. `-f`: This checks if a file exists and is a regular file.

<a id="-d"></a>
3. `-d`: This checks if a directory exists.

<a id="-z"></a>
4. `-z`: This checks if a string is empty.

<a id="-ne"></a>
5. `-ne`: This is a numeric comparison operator that checks if two numbers are not equal.

<a id="set"></a>
6. `set --`: This is used to reset the positional parameters in a shell script.

- The set command in shell scripting is used to manipulate shell options and positional parameters.

- When used with `--` and followed by arguments, `set --` replaces the current set of positional parameters (`$1`, `$2`, `$3`, ..., `$#`, `$@`, `"$*"`) with the arguments that follow `--`.
  - `$1`, `$2`, `$3`, ...: These are the individual positional parameters.
  - `$#`: This variable holds the number of positional parameters.
  - `$@`: This variable expands to all positional parameters as separate words (e.g., `"$1" "$2" "$3"`). This is generally the safest way to access positional parameters.
  - `"$*"`: This variable expands to all positional parameters as a single word, with each parameter separated by the first character of the IFS (Internal Field Separator) variable (usually a space).
- **Example**:
  ```shell
    #!/bin/bash

    echo "Initial parameters: $@"
    echo "Number of parameters: $#"

    set -- "apple" "banana orange" "cherry"

    echo "Parameters after set --: $@"
    echo "Number of parameters: $#"
    echo "First parameter: $1"
    echo "Second parameter: $2"
    echo "Third parameter: $3"
  ``` 
  Output:
  ```
    Initial parameters:
    Number of parameters: 0
    Parameters after set --: apple "banana orange" cherry
    Number of parameters: 3
    First parameter: apple
    Second parameter: banana orange
    Third parameter: cherry
  ```

7. `eval` (The Evil Command - Use with Caution)
eval is a shell built-in command that takes a string as an argument and executes that string as a shell command.
This is where the power and the danger lie. eval performs a second pass of parsing and execution on its argument.