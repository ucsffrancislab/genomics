#	Testing 2-kupl on TCGA sample


Started Nov 3, 7:15

```
python3 -m pip install --user --upgrade pydna



git clone https://github.com/yunfengwang0317/2-kupl.git

mkdir output

cd 2-kupl/script/
export PATH=${PATH}:${HOME}/.local/BBMap/


nohup python3 pipeline.py --m1 /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/19-2629-01A-01D-1495_R1.fastq.gz --m2 /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/19-2629-01A-01D-1495_R2.fastq.gz --w1 /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/19-2629-10A-01D-1495_R1.fastq.gz --w2 /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20200722-bamtofastq/out/19-2629-10A-01D-1495_R2.fastq.gz -o /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20211021-2kupl-test/output/ --type genome > 2kupl.out 2> 2kupl.err &


```

