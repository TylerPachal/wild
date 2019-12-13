#! /bin/sh -

## Created for development/testing
## https://unix.stackexchange.com/questions/556368/writing-a-glob-match-testing-function#556371
##
## Example Usage:
##  ./wildcard_test.sh "foobar" "fooba*"

subject=${1?No subject} pattern=${2?No pattern}
case $subject in
  ($pattern) echo "match"; true;;
  (*)        echo "no match"; false;;
esac