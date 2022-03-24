

See
```
/francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20200910-bamtofastq/
```



Need to install biobambam's bamtofastq

I think that I chose this app because the bam file doesn't need to be presorted.

```
git clone https://gitlab.com/german.tischler/libmaus2.git
git clone https://gitlab.com/german.tischler/biobambam2.git
cd libmaus2/
libtoolize 
aclocal
autoreconf -i -f
./configure --prefix=$HOME/.local
#configure: error: Required class std::unique_ptr<> not found
module load scl-devtoolset/7
./configure --prefix=$HOME/.local
#configure: error: Required std::filesystem functions not found
module load scl-devtoolset/8
./configure --prefix=$HOME/.local
make	#	this takes hours
make install



cd ../biobambam2
autoreconf -i -f
./configure --with-libmaus2=$HOME/.local --prefix=$HOME/.local
make	#	this takes a while as well
make install
```




```
ls -1 /francislab/data1/raw/PRJNA736483/SRR14773*/*_alignment_bam.bam | wc -l
89
```


```
mkdir -p ${PWD}/out
date=$( date "+%Y%m%d%H%M%S" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-89%4 --job-name="bamtofastq" --output="${PWD}/out/bamtofastq.${date}-%A_%a.out" --time=480 --nodes=1 --ntasks=4 --mem=30G --gres=scratch:50G /francislab/data1/working/PRJNA736483/20220310-bamtofastq/bamtofastq_array_wrapper.bash
```




```
scontrol update ArrayTaskThrottle=6 JobId=352083
```


```
zcat out/HMN83551_O1.fastq.gz | sed -n '1~4p' | awk -F/ '{print $1}' > out/HMN83551_O1.names &
zcat out/HMN83551_O2.fastq.gz | sed -n '1~4p' | awk -F/ '{print $1}' > out/HMN83551_O2.names &
zcat out/HMN83551_R2.fastq.gz | sed -n '1~4p' | awk -F/ '{print $1}' > out/HMN83551_R2.names &
zcat out/HMN83551_R1.fastq.gz | sed -n '1~4p' | awk -F/ '{print $1}' > out/HMN83551_R1.names &
comm -12 out/HMN83551_O?.names 
diff out/HMN83551_R?.names 
```

