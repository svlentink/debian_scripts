#!/bin/bash

for d in `find ~ -type d -name '\.git'`; do
  cd $d/..
  git status \
  | grep modified && echo $d
done
