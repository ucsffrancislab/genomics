#!/usr/bin/env bash


gene="EGFR"
url="https://rest.uniprot.org/uniprotkb/P00533.fasta"

#	if the hotspot ends with "fs" like R719fs, R941fs, R933fs, R986fs, I think it is a "frame shift" deletion
#	if it ends with "del", it is an inframe_deletion

while read hotspot ; do
#	echo $hotspot
	mut_from=${hotspot:0:1}
#	echo ${mut_from}
	mut_to=${hotspot: -1}
#	echo "${mut_to}"
	pos=${hotspot#?}
	pos=${pos%?}
#	echo $pos

	sequence=$( tail -n +2 genes_for_hotspots/$( basename $url ) | tr -d '\n' )
#	echo ${sequence:0:100}
#	existing=${sequence:$[pos-2]:3}
	existing=${sequence:$[pos-1]:1}

	if [ "${mut_from}" == "${existing}" ] ; then

		if [ ! "${mut_to}" == "*" ] ; then

			#>EGFR_HotSpot-EGFR:1205-1215:Original
			#SEFIGA
			#>EGFR_HotSpot-EGFR:1205-1215:Mutation:A1210V
			#SEFIGV

			#	Don't include a mutation that is at the end. Not really testable this way

			orig=${sequence:$[pos-6]:11}
			if [ ${#orig} -gt 10 ] ; then
##					echo ">EGFR_HotSpot_${gene}:$[pos-5]-$[pos+5]:Original"
				echo ">EGFR_HotSpot:$[pos-5]-$[pos+5]:Original"
				echo ${sequence:$[pos-6]:11}
##					echo ">EGFR_HotSpot_${gene}:$[pos-5]-$[pos+5]:Mutation:${hotspot}"
				echo ">EGFR_HotSpot:$[pos-5]-$[pos+5]:Mutation:${hotspot}"
				echo ${sequence:$[pos-6]:5}${mut_to}${sequence:$[pos]:5}
			#else
			#	echo "The AA sequence was too short"
			#	exit 3
			fi
		#else
		#	echo "The mutation is to a STOP codon"
		#	exit 2
		fi
	#else
	#	echo "The mutation from AA was not as expected"
	#	exit 1
	fi

#	Could've done this as well ( $1~/>/ && $1~/p./ 
done < <( awk -F"\t" '(( $1!~/-|+|inv|del|fs/ && $2=="EGFR" && $3 != "" && $16~/athogenic/ )){print $1}' clinvar_result.txt | grep -o "(p.*)" | sed -e 's/^(p.//' -e 's/)//' -e 's/Ala/A/g' -e 's/Arg/R/g' -e 's/Asn/N/g' -e 's/Asp/D/g' -e 's/Cys/C/g' -e 's/Glu/E/g' -e 's/Gln/Q/g' -e 's/Gly/G/g' -e 's/His/H/g' -e 's/Ile/I/g' -e 's/Leu/L/g' -e 's/Lys/K/g' -e 's/Met/M/g' -e 's/Phe/F/g' -e 's/Pro/P/g' -e 's/Ser/S/g' -e 's/Thr/T/g' -e 's/Trp/W/g' -e 's/Tyr/Y/g' -e 's/Val/V/g' -e 's/Ter/*/g' )





#	Back to EGFR- Looks like the one we really need is EGFR vIII mutation where deletion of exons 2–7 occurs. Can you make sure we have that one?

#	Couldn't figure out how to include these "fs dup" and "fs del"
#	
#	awk -F"\t"  '(( $2=="EGFR" && $3 != "" && $16~/athogenic/ )){print}' clinvar_result.txt | grep dup
#	NM_005228.5(EGFR):c.797dup (p.Leu267fs)	EGFR	L222fs, L267fs, L214fs	EGFR-related lung cancer	VCV003012073	7	55221747 - 552217455154054 - 55154055	3012073	3173662	rs2128934926	NC_000007.14:55154054:CCCCCC:CCCCCCC	Duplication	frameshift variant|intron variant	Pathogenic	Aug 3, 2023	criteria provided, single submitter							
#	NM_005228.5(EGFR):c.2090_2091dup (p.Ala698fs)	EGFR	A431fs, A645fs, A653fs, A698fs	EGFR-related lung cancer	VCV002695031	7	55241641 - 55241642	7	55173948 - 55173949	2695031	2857738	rs2534724610	NC_000007.14:55173948:AA:AAAA	Duplication	frameshift variant	Pathogenic	Nov 11, 2023	criteria provided, single submitter							



while read hotspot ; do
	#echo $hotspot
	hotspot=${hotspot:3: -5}
#	echo $hotspot

	if [[ "${hotspot}" == *"_"* ]]; then
		r1=${hotspot%_*}
		r2=${hotspot#*_}
	else
		r1=${hotspot}
		r2=${hotspot}
	fi
#	echo "$r1 - $r2"

#	echo "Deletion:$[262+r1-1]-$[262+r2-1]"
	range=$[262+(3*((r1-15)/3))]-$[262+(3*((r1+18)/3))+((r1+18)%3)-1]
#	echo $range
	tail -n +2 NM_005228.5.fna | tr -d "\n" | cut -c${range} | sed "1i>EGFR_HotSpot:${hotspot}del:Original" | pepsyn translate - - 2>/dev/null
	
	#range=$[262+(3*((r1-15)/3))]-$[262+(3*((r1)/3))-1],$[262+(3*((r2)/3))+((r2+1)%3)+1]-$[262+(3*((r2+18)/3))+((r2+18)%3)]
	range=$[262+(3*((r1-15)/3))]-$[262+r1-2],$[262+r2]-$[262+(3*((r2+18)/3))+((r2+18)%3)]
#	echo $range
	tail -n +2 NM_005228.5.fna | tr -d "\n" | cut -c${range} | sed "1i>EGFR_HotSpot:${hotspot}del:Mutation" | pepsyn translate - - 2>/dev/null

#	#	don't want the "delins" - too much
done < <( awk -F"\t" '(( $1~/del / && $2=="EGFR" && $3 != "" && $16~/athogenic/ )){print $1}' clinvar_result.txt | grep -o ":c.* (" )
#| sed -e 's/^(p.//' -e 's/)//' -e 's/Ala/A/g' -e 's/Arg/R/g' -e 's/Asn/N/g' -e 's/Asp/D/g' -e 's/Cys/C/g' -e 's/Glu/E/g' -e 's/Gln/Q/g' -e 's/Gly/G/g' -e 's/His/H/g' -e 's/Ile/I/g' -e 's/Leu/L/g' -e 's/Lys/K/g' -e 's/Met/M/g' -e 's/Phe/F/g' -e 's/Pro/P/g' -e 's/Ser/S/g' -e 's/Thr/T/g' -e 's/Trp/W/g' -e 's/Tyr/Y/g' -e 's/Val/V/g' -e 's/Ter/*/g' )



