#! /bin/sh -

## Created for development/testing
## https://unix.stackexchange.com/questions/556368/writing-a-glob-match-testing-function#556371
##
## Example Usage:
##  ./wildcard_test.sh "foobar" "fooba*"

subject=${1?No subject}
pattern=${2?No pattern}
option=$3

print() {
  message=$1
  if [[ $option == "-v" ]]; then
    echo "[Bash] $message"
  fi
}

print "subject: $subject"
echo -n "$subject" | od -An -tuC | xargs

print "pattern: $pattern"
echo -n "$pattern" | od -An -tuC | xargs

case $subject in
  ($pattern) print "match"; true;;
  (*)        print "no match"; false;;
esac