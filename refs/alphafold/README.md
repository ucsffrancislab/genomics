
#	AlphaFold


https://www.rbvi.ucsf.edu/chimerax/data/singularity-apr2022/afsingularity.html

https://ucsffrancislab.github.io/docs/AlphaFold

https://ucsffrancislab.github.io/docs/Singularity

https://ucsffrancislab.github.io/docs/Docker



```

singularity exec --bind /francislab,/scratch \
 /francislab/data1/refs/alphafold/alphafold233.sif \
 /app/run_docker.sh \
 --data_dir=/francislab/data1/refs/alphafold/databases/ \
 --max_template_date=2020-05-14 \
 --model_preset=monomer \
 --fasta_paths=/francislab/data1/refs/SPELLARDPYGPAVDIWSAGIVLFEMATGQ.faa \
 --output_dir=/francislab/data1/refs/


```




```

singularity exec --bind /francislab,/scratch \
 /francislab/data1/refs/alphafold/alphafold233.sif \
 /app/run_alphafold.sh \
 --bfd_database_path=/francislab/data1/refs/alphafold/databases/bfd/ \
 --uniref30_database_path=/francislab/data1/refs/alphafold/databases/uniref30/ \
 --pdb70_database_path=/francislab/data1/refs/alphafold/databases/pdb70/ \
 --uniref90_database_path=/francislab/data1/refs/alphafold/databases/uniref90/uniref90.fasta \
 --mgnify_database_path=/francislab/data1/refs/alphafold/databases/mgnify/mgy_clusters_2022_05.fa \
 --template_mmcif_dir=/francislab/data1/refs/alphafold/databases/pdb_mmcif/ \
 --obsolete_pdbs_path=/francislab/data1/refs/alphafold/databases/pdb_mmcif/obsolete.dat \
 --use_gpu_relax \
 --data_dir=/francislab/data1/refs/alphafold/databases/ \
 --max_template_date=2020-05-14 \
 --model_preset=monomer \
 --fasta_paths=/francislab/data1/refs/SPELLARDPYGPAVDIWSAGIVLFEMATGQ.faa \
 --output_dir=/francislab/data1/refs/alphafold/


E0916 09:42:31.539167 139887172739712 hhsearch.py:56] Could not find HHsearch database /francislab/data1/refs/alphafold/databases/pdb70/
Traceback (most recent call last):
  File "/app/alphafold/run_alphafold.py", line 570, in <module>
    app.run(main)
  File "/opt/conda/lib/python3.11/site-packages/absl/app.py", line 312, in run
    _run_main(main, args)
  File "/opt/conda/lib/python3.11/site-packages/absl/app.py", line 258, in _run_main
    sys.exit(main(argv))
             ^^^^^^^^^^
  File "/app/alphafold/run_alphafold.py", line 475, in main
    template_searcher = hhsearch.HHSearch(
                        ^^^^^^^^^^^^^^^^^^
  File "/app/alphafold/alphafold/data/tools/hhsearch.py", line 57, in __init__
    raise ValueError(f'Could not find HHsearch database {database_path}')
ValueError: Could not find HHsearch database /francislab/data1/refs/alphafold/databases/pdb70/

```

