#!/bin/bash
FILES= apps/*
for f in $FILES
do
  echo "Processing $f file..."
  #knife data bag from file apps $f
  # take action on each file. $f store current file name
done

