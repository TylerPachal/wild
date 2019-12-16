#!/bin/bash

## Created for development/testing
## https://unix.stackexchange.com/questions/556368/writing-a-glob-match-testing-function#556371
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

# Make a new directory for this file to live under /tmp/wild
dir="/tmp/wild/$(uuidgen)"
mkdir -p $dir

# Switch to fresh directory
pushd $dir > /dev/null

# Create the file
touch $subject

# List files using wild card and count the results
hits=$(ls $pattern -R 2>/dev/null | wc -l)

# Go back to original directory
popd > /dev/null

# Make sure the result is equal to one
if [ $hits == 1 ]; then
  echo "match"
  true
else
  echo "no match"
  false
fi
