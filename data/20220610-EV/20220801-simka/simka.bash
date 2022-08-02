#!/usr/bin/env bash


out=${PWD}/out1
mkdir -p ${out}

tmp=${PWD}/out1-tmp
mkdir -p ${tmp}

~/github/GATB/simka/build/bin/simka -in ${PWD}/datasets1 -out ${out} -out-tmp ${tmp}



out=${PWD}/out2
mkdir -p ${out}

tmp=${PWD}/out2-tmp
mkdir -p ${tmp}

~/github/GATB/simka/build/bin/simka -in ${PWD}/datasets2 -out ${out} -out-tmp ${tmp}



