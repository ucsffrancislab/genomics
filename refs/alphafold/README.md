
#	AlphaFold


https://www.rbvi.ucsf.edu/chimerax/data/singularity-apr2022/afsingularity.html

https://ucsffrancislab.github.io/docs/AlphaFold

https://ucsffrancislab.github.io/docs/Singularity

https://ucsffrancislab.github.io/docs/Docker



```

sbatch --export=NONE --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="Alpha" --output="${PWD}/$( date "+%Y%m%d%H%M%S%N" ).out" --time=2880 \
--nodes=1 --ntasks-per-node=1 --gres=gpu:1 --partition=common --mem=30G \
--wrap="singularity exec --nv --writable-tmpfs \
  --bind /francislab,/scratch \
  /francislab/data1/refs/alphafold/alphafold233.sif \
  /app/run_alphafold.sh \
  --bfd_database_path=/francislab/data1/refs/alphafold/databases/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt \
  --uniref30_database_path=/francislab/data1/refs/alphafold/databases/uniref30/UniRef30_2021_03 \
  --pdb70_database_path=/francislab/data1/refs/alphafold/databases/pdb70/pdb70 \
  --uniref90_database_path=/francislab/data1/refs/alphafold/databases/uniref90/uniref90.fasta \
  --mgnify_database_path=/francislab/data1/refs/alphafold/databases/mgnify/mgy_clusters_2022_05.fa \
  --template_mmcif_dir=/francislab/data1/refs/alphafold/databases/pdb_mmcif/mmcif_files/ \
  --obsolete_pdbs_path=/francislab/data1/refs/alphafold/databases/pdb_mmcif/obsolete.dat \
  --use_gpu_relax \
  --data_dir=/francislab/data1/refs/alphafold/databases/ \
  --max_template_date=2020-05-14 \
  --model_preset=monomer \
  --fasta_paths=/francislab/data1/refs/alphafold/SPELLARDPYGPAVDIWSAGIVLFEMATGQ.faa \
  --output_dir=/francislab/data1/refs/alphafold/"

```


Doesn't seem to use the GPUs.

```
/sbin/ldconfig.real: Can't create temporary cache file /etc/ld.so.cache~: Read-only file system

I0918 11:06:20.239907 140090094478592 xla_bridge.py:863] Unable to initialize backend 'cuda': jaxlib/cuda/versions_helpers.cc:98: operation cuInit(0) failed: Unknown CUDA error 303; cuGetErrorName failed. This probably means that JAX was unable to load the CUDA libraries.
I0918 11:06:20.242466 140090094478592 xla_bridge.py:863] Unable to initialize backend 'rocm': NOT_FOUND: Could not find registered platform with name: "rocm". Available platform names are: CUDA
I0918 11:06:20.243407 140090094478592 xla_bridge.py:863] Unable to initialize backend 'tpu': INTERNAL: Failed to open libtpu.so: libtpu.so: cannot open shared object file: No such file or directory
W0918 11:06:20.243524 140090094478592 xla_bridge.py:898] CUDA backend failed to initialize: jaxlib/cuda/versions_helpers.cc:98: operation cuInit(0) failed: Unknown CUDA error 303; cuGetErrorName failed. This probably means that JAX was unable to load the CUDA libraries. (Set TF_CPP_MIN_LOG_LEVEL=0 and rerun for more info.)

```



Adding `--nv` limits a couple

```
/sbin/ldconfig.real: Can't create temporary cache file /etc/ld.so.cache~: Read-only file system

I0918 13:12:55.901857 139628764833024 xla_bridge.py:863] Unable to initialize backend 'rocm': NOT_FOUND: Could not find registered platform with name: "rocm". Available platform names are: CUDA
I0918 13:12:55.903635 139628764833024 xla_bridge.py:863] Unable to initialize backend 'tpu': INTERNAL: Failed to open libtpu.so: libtpu.so: cannot open shared object file: No such file or directory

```



There's also `--nvccli` but 

```
INFO:    Setting 'NVIDIA_VISIBLE_DEVICES=all' to emulate legacy GPU binding.
INFO:    Setting --writable-tmpfs (required by nvidia-container-cli)
FATAL:   nvidia-container-cli not allowed in setuid mode
```


With --nv, it took 1.5 hours.
Without it, it took 


`--writable-tmpfs` get rid of the line 
```
/sbin/ldconfig.real: Can't create temporary cache file /etc/ld.so.cache~: Read-only file system
```
Yay!






```

sbatch --export=NONE --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="Test" --output="${PWD}/Test.$( date "+%Y%m%d%H%M%S%N" ).out" --time=288 --nodes=1 --ntasks-per-node=1 --gres=gpu:1 --partition=common --mem=30G --wrap="singularity exec --writable-tmpfs --nv alphafold233.sif python3 -c \"import tensorflow as tf; print('Num GPUs Available: ',len(tf.config.experimental.list_physical_devices('GPU'))); print('Tensorflow version: ',tf.__version__)\""

```



singularity pull docker://tensorflow/tensorflow:latest-gpu

singularity exec --writable-tmpfs --nv tensorflow_latest-gpu.sif bash









```

ssh -t gwendt@c4-log1 ssh gwendt@c4-gpudev1


singularity pull docker://tensorflow/tensorflow:latest-gpu

nvidia-smi


singularity exec --writable-tmpfs --nv tensorflow_latest-gpu.sif bash

nvidia-smi

python3 

import tensorflow as tf
print('Tensorflow version: ',tf.__version__)

print('Num GPUs Available: ',len(tf.config.experimental.list_physical_devices('GPU')))

print(tf.config.list_physical_devices('GPU'))

from tensorflow.python.client import device_lib
print(device_lib.list_local_devices())

```




