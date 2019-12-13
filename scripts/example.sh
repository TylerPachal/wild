#!/bin/bash

a="\\"
b="\\"

echo "Input:"
echo $a
echo $b
echo "Result:"

if [[ "$a" == "$b" ]]; then
  echo "match"
  exit 0
else
  echo "no match"
  exit 1
fi
