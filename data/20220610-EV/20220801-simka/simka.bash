#!/usr/bin/env bash


out=${PWD}/out
mkdir -p ${out}

tmp=${PWD}/out-tmp
mkdir -p ${tmp}

~/github/GATB/simka/build/bin/simka -in ${PWD}/datasets -out ${out} -out-tmp ${tmp}



