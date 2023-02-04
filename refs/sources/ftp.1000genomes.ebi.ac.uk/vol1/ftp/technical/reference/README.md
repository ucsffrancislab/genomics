

```

wget http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/human_g1k_v37.fasta.fai
mv human_g1k_v37.fasta.fai human_g1k_v37.fa.fai

wget http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/human_g1k_v37.fasta.gz
mv human_g1k_v37.fasta.gz human_g1k_v37.fa.gz
gunzip human_g1k_v37.fa.gz


```



```

module load bwa
bwa index human_g1k_v37.fa

```


```

tar cvf human_g1k_v37.tar human_g1k_v37.fa.{amb,ann,bwt,pac,sa}

```



Upload


python3
```

import sevenbridges as sbg
c = sbg.Config(profile='cgc')
api = sbg.Api(config=c)
project = api.projects.get(id='wendt2017/sgdp')
refs=api.files.query(project=project,names=['references'],limit=1)[0]
api.files.upload('human_g1k_v37.fa', parent=refs)
api.files.upload('human_g1k_v37.fa.fai', parent=refs)

bwa=api.files.query(parent=refs.id,names=['bwa'],limit=1)[0]
api.files.upload('human_g1k_v37.tar', parent=bwa)

```






