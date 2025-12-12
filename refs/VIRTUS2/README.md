
#	refs/VIRTUS2



By default, this requires docker. To force singularity, you need to call it a bit different than described ...

```bash
cwltool --singularity \
	~/github/yyoshiaki/VIRTUS2/bin/createindex.cwl \
	https://raw.githubusercontent.com/yyoshiaki/VIRTUS2/master/workflow/createindex.job.yaml
```

This will use all threads so don't do this on dev3.

```bash
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=64 --mem=490G --export=None --job-name=VIRTUS2 \
--wrap="cwltool --debug --singularity \
	~/github/yyoshiaki/VIRTUS2/bin/createindex.cwl \
	https://raw.githubusercontent.com/yyoshiaki/VIRTUS2/master/workflow/createindex.job.yaml"
```

OK. Can't do that. Nodes don't have outside access and this script downloads.

Limit threads

```bash

cwltool --debug --singularity \
  ~/github/yyoshiaki/VIRTUS2/bin/createindex.cwl --runThreadN 4 \
  https://raw.githubusercontent.com/yyoshiaki/VIRTUS2/master/workflow/createindex.job.yaml

```






All params are in the yaml file and doesn't provide easy override ability.

```bash
curl -s https://raw.githubusercontent.com/yyoshiaki/VIRTUS2/master/workflow/createindex.job.yaml | sed '/runThreadN/s/40/4/' > createindex.job.yaml

cwltool --singularity ~/github/yyoshiaki/VIRTUS2/bin/createindex.cwl createindex.job.yaml

```




