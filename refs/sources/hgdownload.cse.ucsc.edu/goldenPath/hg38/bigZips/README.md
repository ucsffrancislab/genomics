

#	Reference Inconsistencies

https://hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/


Create sorted uniq lists of chromosomes in each reference file ...
```
cut -f1 genes/hg38.ncbiRefSeq.gtf | sort | uniq > genes/hg38.ncbiRefSeq.gtf.chromosomes

grep "^>" latest/hg38.fa | sed 's/^>//' | sort > latest/hg38.fa.chromosomes

wc -l genes/hg38.ncbiRefSeq.gtf.chromosomes latest/hg38.fa.chromosomes 
  421 genes/hg38.ncbiRefSeq.gtf.chromosomes
  595 latest/hg38.fa.chromosomes
 1016 total
```

Use comm to compare the lists ...
```
comm -h
       -1     suppress column 1 (lines unique to FILE1)

       -2     suppress column 2 (lines unique to FILE2)

       -3     suppress column 3 (lines that appear in both files)
```

```
comm -13 genes/hg38.ncbiRefSeq.gtf.chromosomes latest/hg38.fa.chromosomes 
```

The following sequences are ONLY in hg38.fa (n=174).
```
chr10_KN538365v1_fix
chr10_KN538367v1_fix
chr11_GL383547v1_alt
chr12_GL383549v1_alt
chr12_KI270836v1_alt
chr12_KI270837v1_alt
chr12_KN196482v1_fix
chr13_KI270841v1_alt
chr13_KI270843v1_alt
chr13_KN196483v1_fix
chr13_KQ090024v1_alt
chr14_GL000225v1_random
chr14_KI270722v1_random
chr14_KI270723v1_random
chr14_KI270724v1_random
chr14_KI270725v1_random
chr16_KQ031390v1_alt
chr17_GL383565v1_alt
chr17_KI270729v1_random
chr17_KI270730v1_random
chr17_KI270858v1_alt
chr17_KI270859v1_alt
chr17_KZ559114v1_alt
chr18_GL383568v1_alt
chr18_GL383570v1_alt
chr18_KI270864v1_alt
chr1_KI270707v1_random
chr1_KI270708v1_random
chr1_KI270709v1_random
chr1_KI270710v1_random
chr1_KI270714v1_random
chr1_KI270764v1_alt
chr1_KQ458382v1_alt
chr1_KZ208905v1_alt
chr1_KZ559100v1_fix
chr21_GL383578v2_alt
chr22_KI270732v1_random
chr22_KI270735v1_random
chr22_KI270736v1_random
chr22_KI270737v1_random
chr22_KI270738v1_random
chr22_KI270739v1_random
chr2_KI270715v1_random
chr2_KI270716v1_random
chr2_KI270771v1_alt
chr2_KI270775v1_alt
chr2_KZ208907v1_alt
chr3_KI270778v1_alt
chr3_KQ031386v1_fix
chr3_KZ559101v1_alt
chr4_KI270787v1_alt
chr4_KI270788v1_alt
chr5_GL000208v1_random
chr6_KI270799v1_alt
chr6_KN196478v1_fix
chr6_KQ031387v1_fix
chr6_KQ090017v1_alt
chr7_KI270807v1_alt
chr7_KZ559106v1_alt
chr9_GL383539v1_alt
chr9_GL383542v1_alt
chr9_KI270717v1_random
chr9_KQ090018v1_alt
chr9_KQ090019v1_alt
chrUn_GL000216v2
chrUn_GL000226v1
chrUn_KI270302v1
chrUn_KI270303v1
chrUn_KI270304v1
chrUn_KI270305v1
chrUn_KI270310v1
chrUn_KI270311v1
chrUn_KI270312v1
chrUn_KI270315v1
chrUn_KI270316v1
chrUn_KI270317v1
chrUn_KI270320v1
chrUn_KI270322v1
chrUn_KI270329v1
chrUn_KI270330v1
chrUn_KI270333v1
chrUn_KI270334v1
chrUn_KI270335v1
chrUn_KI270336v1
chrUn_KI270337v1
chrUn_KI270338v1
chrUn_KI270340v1
chrUn_KI270362v1
chrUn_KI270363v1
chrUn_KI270364v1
chrUn_KI270366v1
chrUn_KI270371v1
chrUn_KI270372v1
chrUn_KI270373v1
chrUn_KI270374v1
chrUn_KI270375v1
chrUn_KI270376v1
chrUn_KI270378v1
chrUn_KI270379v1
chrUn_KI270381v1
chrUn_KI270382v1
chrUn_KI270383v1
chrUn_KI270384v1
chrUn_KI270385v1
chrUn_KI270386v1
chrUn_KI270387v1
chrUn_KI270388v1
chrUn_KI270389v1
chrUn_KI270390v1
chrUn_KI270391v1
chrUn_KI270392v1
chrUn_KI270393v1
chrUn_KI270394v1
chrUn_KI270395v1
chrUn_KI270396v1
chrUn_KI270411v1
chrUn_KI270412v1
chrUn_KI270414v1
chrUn_KI270417v1
chrUn_KI270418v1
chrUn_KI270419v1
chrUn_KI270420v1
chrUn_KI270422v1
chrUn_KI270423v1
chrUn_KI270424v1
chrUn_KI270425v1
chrUn_KI270429v1
chrUn_KI270435v1
chrUn_KI270438v1
chrUn_KI270448v1
chrUn_KI270465v1
chrUn_KI270466v1
chrUn_KI270467v1
chrUn_KI270468v1
chrUn_KI270507v1
chrUn_KI270508v1
chrUn_KI270509v1
chrUn_KI270510v1
chrUn_KI270511v1
chrUn_KI270512v1
chrUn_KI270515v1
chrUn_KI270516v1
chrUn_KI270517v1
chrUn_KI270518v1
chrUn_KI270519v1
chrUn_KI270521v1
chrUn_KI270522v1
chrUn_KI270528v1
chrUn_KI270529v1
chrUn_KI270530v1
chrUn_KI270538v1
chrUn_KI270539v1
chrUn_KI270544v1
chrUn_KI270548v1
chrUn_KI270579v1
chrUn_KI270580v1
chrUn_KI270581v1
chrUn_KI270582v1
chrUn_KI270583v1
chrUn_KI270584v1
chrUn_KI270587v1
chrUn_KI270588v1
chrUn_KI270589v1
chrUn_KI270590v1
chrUn_KI270591v1
chrUn_KI270593v1
chrUn_KI270747v1
chrUn_KI270749v1
chrUn_KI270752v1
chrUn_KI270756v1
chrUn_KI270757v1
chrX_KV766199v1_alt
chrY_KI270740v1_random
chrY_KZ208923v1_fix
```
Is it possible/plausible that all of these do not contain anything worth annotating? Nah.


The following sequences are ONLY in hg38.ncbiRefSeq.gtf. (n=0)
```
comm -23 genes/hg38.ncbiRefSeq.gtf.chromosomes latest/hg38.fa.chromosomes 
```




