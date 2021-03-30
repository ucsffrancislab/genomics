#!/usr/bin/env bash

qdel $( squeue --me | awk '($8 ~ /DependencyNeverSatisfied/){ print $1 }' | paste -sd " " )

