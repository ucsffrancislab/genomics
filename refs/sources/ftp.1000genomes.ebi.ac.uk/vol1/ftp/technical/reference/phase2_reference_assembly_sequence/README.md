

Downloading older reference for use with MELT


```

wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz.fai
mv hs37d5.fa.gz.fai hs37d5.fa.fai

wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz
gunzip hs37d5.fa.gz

```


It appears to be the final version of hg19.

Dated 3/16/2017





```

module load bwa
bwa index hs37d5.fa

```


```

tar cvf hs37d5.tar hs37d5.fa.{amb,ann,bwt,pac,sa}

```



Upload


python3
```

import sevenbridges as sbg
c = sbg.Config(profile='cgc')
api = sbg.Api(config=c)
project = api.projects.get(id='wendt2017/sgdp')
refs=api.files.query(project=project,names=['references'],limit=1)[0]
api.files.upload('hs37d5.fa', parent=refs)
api.files.upload('hs37d5.fa.fai', parent=refs)

bwa=api.files.query(parent=refs.id,names=['bwa'],limit=1)[0]
api.files.upload('hs37d5.tar', parent=bwa)

```







