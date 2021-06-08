#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module' IN THIS SCRIPT OR ANY THAT ARE CALLED

~/.local/SNP2HLA_package_v1.0.3/SNP2HLA/SNP2HLA.csh $@

