  #!/bin/bash

  echo "Initial parameters: $@"
  echo "Number of parameters: $#"

  set -- "apple" "banana orange" "cherry"

  echo "Parameters after set --: $@"
  echo "Number of parameters: $#"
  echo "First parameter: $1"
  echo "Second parameter: $2"
  echo "Third parameter: $3"