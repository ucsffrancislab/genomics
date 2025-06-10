#!/usr/bin/env bash


\rm -f tmp*.csv

cat oligos-ref-28-14.fasta | paste - - | awk 'BEGIN{OFS=","}{gsub("^>","",$1);print $1,$2,NR}' | sort -t, -k1,1 | sed '1iname,oligo,unique_id' > oligos-ref-28-14.csv

cat protein_tiles-28-14.fasta | paste - - | awk 'BEGIN{OFS=","}{gsub("^>","",$1);split($1,a,"|");print $1,a[1],$2}' | sort -t, -k1,1 | sed '1iname,group,peptide' > protein_tiles-28-14.csv

join --header -t, protein_tiles-28-14.csv oligos-ref-28-14.csv > protein_tiles-oligos-28-14.csv


cat unique_proteins.faa | paste - - | awk 'BEGIN{OFS=","}{gsub("^>","",$1);print $1,$2}' | sort -t, -k1,1 | sed '1igroup,protein' > unique_proteins.csv

#	This list includes extra duplicated proteins that were not tiled. Somehow they need included in the final product.
#cat sorted_proteins.faa | paste - - | awk 'BEGIN{OFS=","}{gsub("^>","",$1);print $1,$2}' | sort -t, -k1,1 | sed '1igroup,protein' > sorted_proteins.csv



join -t, -1 1 -2 2 <( tail -n +2 unique_proteins.csv ) <( tail -n +2 protein_tiles-oligos-28-14.csv | sort -t, -k2,2 ) | sed '1iprotein_sequence_name,protein_sequence,tile_name,peptide_sequence,oligo_sequence,unique_id' > protein_protein_tiles-oligos-28-14.csv

#	join -t, -1 1 -2 2 <( tail -n +2 sorted_proteins.csv ) <( tail -n +2 protein_tiles-oligos-28-14.csv | sort -t, -k2,2 ) | sed '1iprotein_name,protein,tile_name,peptide,oligo,unique_id' > protein_protein_tiles-oligos-28-14.csv

#join -t, -1 2 -2 2 <( tail -n +2 sorted_proteins.csv | sort -t, -k2,2 ) <( tail -n +2 protein_protein_tiles-oligos-28-14.csv | sort -t, -k2,2 ) | sed '1iprotein,protein_name1,protein_name2,tile_name,peptide,oligo,unique_id' > protein_protein_protein_tiles-oligos-28-14.csv
#for p in $( diff unique_proteins.csv sorted_proteins.csv | grep "^>" | cut -d, -f2 ) ; do
#echo 
#awk -F, -v p=$p '($1==p)' protein_protein_protein_tiles-oligos-28-14.csv
#done

#	for p in $( diff unique_proteins.csv sorted_proteins.csv | grep "^>" | cut -d, -f2 ) ; do echo ; awk -F, -v p=$p '($2==p)' sorted_proteins.csv; done


#	Notable duplicates that need managed somehow

#	EGFR_HotSpot:594-602:Original,TCPAGVMGE
#	HotSpot_EGFR:594-602:Original,TCPAGVMGE
#	
#	HotSpot_HRAS:57-65:Mutation:Q61R,DTAGREEYS
#	HotSpot_NRAS:57-65:Mutation:Q61R,DTAGREEYS
#	
#	HotSpot_HRAS:57-65:Original,DTAGQEEYS
#	HotSpot_NRAS:57-65:Original,DTAGQEEYS
#	
#	HotSpot_HRAS:57-65:Original,DTAGQEEYS
#	HotSpot_NRAS:57-65:Original,DTAGQEEYS
#	
#	Darwin_ALEEKKGNYV,ALEEKKGNYV
#	NeoPeptidesShi_ALEEKKGNYV,ALEEKKGNYV
#	
#	NeoEpitope_FPRGLWSI,FPRGLWSI
#	NeoPeptidesShi_FPRGLWSI,FPRGLWSI
#	
#	NeoEpitope_FPRGLWSIL,FPRGLWSIL
#	NeoPeptidesShi_FPRGLWSIL,FPRGLWSIL
#	
#	NeoEpitope_GLWSILPMS,GLWSILPMS
#	NeoPeptidesShi_GLWSILPMS,GLWSILPMS
#	
#	NeoEpitope_RGLWSILPM,RGLWSILPM
#	NeoPeptidesShi_RGLWSILPM,RGLWSILPM
#	
#	NeoEpitope_RTFPRGLWSI,RTFPRGLWSI
#	NeoPeptidesShi_RTFPRGLWSI,RTFPRGLWSI
#	
#	RefSeqVZV_NP_040186.1_virion_protein_US10_Human_alphaherpesvirus_3,
#	RefSeqVZV_NP_040191.1_virion_protein_US10_Human_alphaherpesvirus_3,
#	
#	RefSeqVZV_NP_040185.1_regulatory_protein_ICP22_Human_alphaherpesvirus_3,
#	RefSeqVZV_NP_040192.1_regulatory_protein_ICP22_Human_alphaherpesvirus_3,
#	
#	RefSeqVZV_NP_040184.1_transcriptional_regulator_ICP4_Human_alphaherpesvirus_3,
#	RefSeqVZV_NP_040193.1_transcriptional_regulator_ICP4_Human_alphaherpesvirus_3,
#	
#	TCONS_00004305-93-kozak,
#	TCONS_00004307-24-kozak,
#	
#	TCONS_00028203-178-kozak,
#	TCONS_00028205-178-kozak,
#	
#	TCONS_00040298-1086-kozak,
#	TCONS_00040300-610-kozak,
#	
#	VirScanCMV_115278,LKAWEERQQNLQQRQQQPPPPARKPSASRRLFGSSADEDDDDDDDEKNIFTPIKKP <-
#	VirScanCMV_25297,LKAWEERQQNLQQRQQQPPPPARKPSASRRLFGSSADEDDDDDDDEKNIFTPIKKP
#	VirScanPublicEpitope_25297,LKAWEERQQNLQQRQQQPPPPARKPSASRRLFGSSADEDDDDDDDEKNIFTPIKKP
#	
#	VirScanCMV_115279,RRLFGSSADEDDDDDDDEKNIFTPIKKPGTSGKGAASGGGVSSIFSGLLSSGSQKP <-
#	VirScanCMV_25298,RRLFGSSADEDDDDDDDEKNIFTPIKKPGTSGKGAASGGGVSSIFSGLLSSGSQKP
#	
#	VirScanCMV_115280,GTSGKGAASGGGVSSIFSGLLSSGSQKPTSGPLNIPQQQQRHAAFSLVSPQVTKAS <-
#	VirScanCMV_25299,GTSGKGAASGGGVSSIFSGLLSSGSQKPTSGPLNIPQQQQRHAAFSLVSPQVTKAS
#	VirScanPublicEpitope_25299,GTSGKGAASGGGVSSIFSGLLSSGSQKPTSGPLNIPQQQQRHAAFSLVSPQVTKAS
#	
#	VirScanCMV_115281,TSGPLNIPQQQQRHAAFSLVSPQVTKASPGRVRRDSAWDVRPLTETRGDLFSGDED <-
#	VirScanCMV_25300,TSGPLNIPQQQQRHAAFSLVSPQVTKASPGRVRRDSAWDVRPLTETRGDLFSGDED
#	
#	VirScanCMV_115286,QTPVNGNSPWAPTAPLPGDMNPANWPRERAWALKNPHLAYNPFRMPTTSTASQNTV <-
#	VirScanCMV_25305,QTPVNGNSPWAPTAPLPGDMNPANWPRERAWALKNPHLAYNPFRMPTTSTASQNTV
#	VirScanPublicEpitope_25305,QTPVNGNSPWAPTAPLPGDMNPANWPRERAWALKNPHLAYNPFRMPTTSTASQNTV
#	
#	VirScanCMV_115287,RAWALKNPHLAYNPFRMPTTSTASQNTVSTTPRRPSTPRAAVTQTASRDAADEVWA <-
#	VirScanCMV_25306,RAWALKNPHLAYNPFRMPTTSTASQNTVSTTPRRPSTPRAAVTQTASRDAADEVWA
#	
#	VirScanCMV_115288,STTPRRPSTPRAAVTQTASRDAADEVWALRDQTAESPVEDSEEEDDDSSDTGSVVS <-
#	VirScanCMV_25307,STTPRRPSTPRAAVTQTASRDAADEVWALRDQTAESPVEDSEEEDDDSSDTGSVVS
#	
#	VirScanCMV_115296,VGVPSLKPTLGGKAVVGRPPSVPVSGSAPGRLSGSSRAASTTPTYPAVTTVYPPSS <-
#	VirScanCMV_25315,VGVPSLKPTLGGKAVVGRPPSVPVSGSAPGRLSGSSRAASTTPTYPAVTTVYPPSS
#	
#	VirScanCMV_115298,TAKSSVSNAPPVASPSILKPGASAALQSRRSTGTAAVGSPVKSTTGMKTVAFDLSS <-
#	VirScanCMV_25317,TAKSSVSNAPPVASPSILKPGASAALQSRRSTGTAAVGSPVKSTTGMKTVAFDLSS
#	
#	VirScanCMV_115299,RRSTGTAAVGSPVKSTTGMKTVAFDLSSPQKSGTGPQPGSAGMGGAKTPSDAVQNI <-
#	VirScanCMV_25318,RRSTGTAAVGSPVKSTTGMKTVAFDLSSPQKSGTGPQPGSAGMGGAKTPSDAVQNI
#	
#	VirScanCMV_27181,MSGNFTEKHFVNVGIVSQSYMDRLQVSGEQYHHDERGAYFEWNIGGHPVTHTVDMV <-
#	VirScanCMV_60281,MSGNFTEKHFVNVGIVSQSYMDRLQVSGEQYHHDERGAYFEWNIGGHPVTHTVDMV
#	
#	VirScanCMV_115278,LKAWEERQQNLQQRQQQPPPPARKPSASRRLFGSSADEDDDDDDDEKNIFTPIKKP <-
#	VirScanCMV_25297,LKAWEERQQNLQQRQQQPPPPARKPSASRRLFGSSADEDDDDDDDEKNIFTPIKKP
#	VirScanPublicEpitope_25297,LKAWEERQQNLQQRQQQPPPPARKPSASRRLFGSSADEDDDDDDDEKNIFTPIKKP
#	
#	VirScanCMV_115280,GTSGKGAASGGGVSSIFSGLLSSGSQKPTSGPLNIPQQQQRHAAFSLVSPQVTKAS <-
#	VirScanCMV_25299,GTSGKGAASGGGVSSIFSGLLSSGSQKPTSGPLNIPQQQQRHAAFSLVSPQVTKAS
#	VirScanPublicEpitope_25299,GTSGKGAASGGGVSSIFSGLLSSGSQKPTSGPLNIPQQQQRHAAFSLVSPQVTKAS
#	
#	VirScanCMV_115286,QTPVNGNSPWAPTAPLPGDMNPANWPRERAWALKNPHLAYNPFRMPTTSTASQNTV <-
#	VirScanCMV_25305,QTPVNGNSPWAPTAPLPGDMNPANWPRERAWALKNPHLAYNPFRMPTTSTASQNTV
#	VirScanPublicEpitope_25305,QTPVNGNSPWAPTAPLPGDMNPANWPRERAWALKNPHLAYNPFRMPTTSTASQNTV
#	
#	VirScanCMV_32211,KKKPSKHHHHQQSSIMQETDDLDEEDTSIYLSPPPVPPVQVVAKRLPRPDTPRTPR <-
#	VirScanPublicEpitope_32211,KKKPSKHHHHQQSSIMQETDDLDEEDTSIYLSPPPVPPVQVVAKRLPRPDTPRTPR
#	
#	VirScanCMV_32244,LDGQTGTQDKGQKPNLLDRLRHRKNGYRHLKDSDEEENV <-
#	VirScanPublicEpitope_32244,LDGQTGTQDKGQKPNLLDRLRHRKNGYRHLKDSDEEENV
#	
#	VirScanCMV_33882,TASGEEVAVLSHHDSLESRRLREEEDDDDDEDFEDA <-
#	VirScanPublicEpitope_33882,TASGEEVAVLSHHDSLESRRLREEEDDDDDEDFEDA
#	
#	VirScanCommon_52913,PGGSGSGPRHRDGVRRPQKRPSCIGCKGAHGGTGAGGGAGAGGAGAGGAGAGGAGA <-
#	VirScanPublicEpitope_52913,PGGSGSGPRHRDGVRRPQKRPSCIGCKGAHGGTGAGGGAGAGGAGAGGAGAGGAGA
#	
#	VirScanCMV_60278,SHATSSAHNGSHTSRTTSAQTRSVSSQHVTSSEAVSHRANETIYNTTLKYGDVVG <-
#	VirScanPublicEpitope_60278,SHATSSAHNGSHTSRTTSAQTRSVSSQHVTSSEAVSHRANETIYNTTLKYGDVVG
#	
#	VirScanCMV_67524,VTQTASRDAADEVWALRDQTAESPVEDSEEEDDSSDTGSVVSLGHTTPSSDYNNDV <-
#	VirScanPublicEpitope_67524,VTQTASRDAADEVWALRDQTAESPVEDSEEEDDSSDTGSVVSLGHTTPSSDYNNDV




#	awk 'BEGIN{FS=OFS=","}(NR==1){print "unique_id,"$0",group,source,virscanid"}(NR>1){split($1,a,"_");if(a[1]~/VirScan/){s="VirScan";vid=a[length(a)]}else{s=a[1];vid=""}print NR,$0,a[1],s,vid}' protein_protein_tiles-oligos-28-14.csv > tmp1.csv
#	head -1 tmp1.csv > tmp2.csv
#	tail -n +2 tmp1.csv | sort -t, -k9,9 >> tmp2.csv
#	join --header -t, -1 9 -2 1 -a 1 -o auto tmp2.csv /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species_protein.uniq.csv > neoantigen_dataset.csv

awk 'BEGIN{FS=OFS=","}(NR==1){print $0",group,source,virscan_id"}(NR>1){split($1,a,"_");if(a[1]~/VirScan/){s="VirScan";vid=a[length(a)]}else{s=a[1];vid=""}print $0,a[1],s,vid}' protein_protein_tiles-oligos-28-14.csv > tmp1.csv
#	protein_name,protein,tile_name,peptide,oligo,unique_id,group,source,virscanid
head -1 tmp1.csv > tmp2.csv
tail -n +2 tmp1.csv | sort -t, -k9,9 >> tmp2.csv
join --header -t, -1 9 -2 1 -a 1 -o auto tmp2.csv /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species_protein.uniq.csv > tmp3.csv
#	virscan_id,protein_sequence_name,protein_sequence,tile_name,peptide,oligo,unique_id,group,source,species,protein_name
sed -i -e "s/_Human_alphaherpesvirus_3//g" tmp3.csv
sed -i -e '/RefSeqVZV/s/,,$/,Human herpesvirus 3,/' tmp3.csv


#	Add "virscan public epitope" column
join -t, -a 1 -o auto <( tail -n +2 tmp3.csv ) <( awk -F, '(NR>1){print $1","$2",Public"}' ../VirScan/public_epitope_annotations.join_sorted.csv ) | sed '1ivirscan_id,protein_sequence_name,protein_sequence,tile_name,peptide_sequence,oligo_sequence,unique_id,group,source,virscan_species,virscan_protein_name,public_epitope_species,public_epitope' > tmp4.csv


#	Add protein length column
awk 'BEGIN{FS=OFS=","}(NR==1){print $0,"protein_sequence_length"}(NR>1){print $0,length($3)}' tmp4.csv > tmp5.csv

#awk 'BEGIN{FS=OFS=","}(NR==1){print $7,$1,$2,$3,$4,$5,$6,$8,$9,$10,$11,$12,$13,$14,"positions"}(NR>1){ print $7,$1,$2,$3,$4,$5,$6,$8,$9,$10,$11,$12,$13,$14,substr($4,1+index($4,"|"))}' tmp5.csv > tmp6.csv

awk 'BEGIN{FS=OFS=","}(NR==1){print $7,$1,$2,$3,$4,$5,$6,$8,$9,$10,$11,$12,$13,$14,"positions","start_position","stop_position"}(NR>1){
if( $4 == "CTERM|STOP" ){ 
s1=length($3)-1-28;s2=length($3)-1
}else if( $4 ~ "CTERM|STOP|C-PADDED" ){
s1=0;s2=length($3)
}else{
split($4,a,"|");split(a[2],b,"-");s1=b[1];s2=b[2];
}
print $7,$1,$2,$3,$4,$5,$6,$8,$9,$10,$11,$12,$13,$14,substr($4,1+index($4,"|")),s1,s2}' tmp5.csv > tmp6.csv

#	extract peptide positions

#	if its just ... split by dash and save the start and stop positions
#	196-224

#	If its ... then its the whole sequence length 0 - ?
#	CTERM|STOP|C-PADDED-17

#	If its just ... then its the last 27 plus a stop codon.
#	CTERM|STOP




head -1 tmp6.csv > neoantigen_dataset.csv
tail -n +2 tmp6.csv | sort -t, -k1,1 >> neoantigen_dataset.csv


#head -2 neoantigen_dataset.csv 
#unique_id,virscan_id,protein_sequence_name,protein_sequence,tile_name,peptide_sequence,oligo_sequence,group,source,virscan_species,virscan_protein_name,public_epitope_species,public_epitope,protein_sequence_length
#1,,EGFRComplete,long protein,EGFRComplete|0-28,MRPSGTAGAALLALLAALCPASRALEEK,ATGCGTCCGTCAGGTACAGCCGGTGCCGCCTTACTGGCATTGCTGGCAGCACTGTGCCCGGCAAGTCGCGCGCTGGAAGAGAAA,EGFRComplete,EGFRComplete,,,,,17



#\rm tmp*.csv

