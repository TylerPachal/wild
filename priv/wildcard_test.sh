#! /bin/bash

## Created for development/testing
##
## Example Usage:
##  ./wildcard_test.sh "foobar" "fooba*"

subject=${1?No subject}
pattern=${2?No pattern}
option=$3

if [[ $option == "-v" ]]; then
  echo "subject: $subject"
  echo -n $subject | od -An -tuC | xargs

  echo "pattern: $pattern"
  echo -n $pattern | od -An -tuC | xargs
fi

case $subject in
  ($pattern) echo "match"; true;;
  (*)        echo "no match"; false;;
esac
