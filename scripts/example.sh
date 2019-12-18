#!/bin/bash

test () {
  subject=$1
  pattern=$2
  echo "----------------"
  echo "$subject vs $pattern"
  case $subject in
    ($pattern) echo "match";;
    (*)        echo "no match";;
  esac
}

# Test question mark
test "a" "?"

# Test asterisk
test "foobar" "*"

# Test literal
test "a" "a"

# Test backslash
test "\\" "\\"
