
#	RCSB PDB (Protein Data Bank)

https://www.rcsb.org/

https://1d-coordinates.rcsb.org/


PDB ids are (currently) 4 character strings followed by a single number or letter.


Converting these to NCBI ids, or vice versa, is tricky. Sadly there isn't a nice csv translation table. And the relationship isn't one-to-one.


experimental PDB structures (e.g., 4HHB) and Computed Structure Models (CSMs) (e.g., AF_AFP44795F1).


enum SequenceReference {
  NCBI_GENOME
  NCBI_PROTEIN
  UNIPROT
  PDB_ENTITY
  PDB_INSTANCE
}



```
curl https://1d-coordinates.rcsb.org/graphql?query=$(echo '{alignment(from:NCBI_PROTEIN,to:PDB_ENTITY,queryId:"XP_642496"){target_alignment{target_id}}}' | jq -Rr @uri )

{"data":{"alignment":{"target_alignment":[{"target_id":"AF_AFQ86KR9F1_1"},{"target_id":"6T8M_1"}]}}}


curl https://1d-coordinates.rcsb.org/graphql?query=$(echo '{alignment(from:NCBI_PROTEIN,to:PDB_INSTANCE,queryId:"XP_642496"){target_alignment{target_id}}}' | jq -Rr @uri )

{"data":{"alignment":{"target_alignment":[{"target_id":"AF_AFQ86KR9F1.A"},{"target_id":"6T8M.A"},{"target_id":"6T8M.B"},{"target_id":"6T8M.C"}]}}}



curl https://1d-coordinates.rcsb.org/graphql?query=$(echo '{alignment(from:NCBI_PROTEIN,to:UNIPROT,queryId:"XP_642496"){target_alignment{target_id}}}' | jq -Rr @uri )

{"data":{"alignment":{"target_alignment":[{"target_id":"Q86KR9"}]}}}


curl https://1d-coordinates.rcsb.org/graphql?query=$(echo '{alignment(from:NCBI_PROTEIN,to:NCBI_GENOME,queryId:"XP_642496"){target_alignment{target_id}}}' | jq -Rr @uri )

{"data":{"alignment":{"target_alignment":[{"target_id":"NC_007088"}]}}}
```




##	20241125



https://www.rcsb.org/search?request=%7B%22query%22%3A%7B%22type%22%3A%22group%22%2C%22logical_operator%22%3A%22and%22%2C%22nodes%22%3A%5B%7B%22type%22%3A%22group%22%2C%22logical_operator%22%3A%22and%22%2C%22nodes%22%3A%5B%7B%22type%22%3A%22group%22%2C%22nodes%22%3A%5B%7B%22type%22%3A%22terminal%22%2C%22service%22%3A%22text%22%2C%22parameters%22%3A%7B%22attribute%22%3A%22rcsb_entity_source_organism.taxonomy_lineage.name%22%2C%22operator%22%3A%22exact_match%22%2C%22negation%22%3Afalse%2C%22value%22%3A%22Homo%20sapiens%22%7D%7D%5D%2C%22logical_operator%22%3A%22and%22%7D%5D%2C%22label%22%3A%22text%22%7D%5D%7D%2C%22return_type%22%3A%22entry%22%2C%22request_options%22%3A%7B%22paginate%22%3A%7B%22start%22%3A0%2C%22rows%22%3A25%7D%2C%22results_content_type%22%3A%5B%22experimental%22%5D%2C%22sort%22%3A%5B%7B%22sort_by%22%3A%22score%22%2C%22direction%22%3A%22desc%22%7D%5D%2C%22scoring_strategy%22%3A%22combined%22%7D%2C%22request_info%22%3A%7B%22query_id%22%3A%225cd67aba278ae7d621fe76fe2ec196f5%22%7D%7D



71251 Homo Sapian structures

Download in 8 different batches


```
cd homo_sapiens_cifs
for r in 00001-10000 10001-20000 20001-30000 30001-40000 40001-50000 50001-60000 60001-70000 70001-71251 ; do
echo $r
mkdir $r
cd $r
../../batch_download.sh -c -f ../../rcsb_pdb_ids_5cd67aba278ae7d621fe76fe2ec196f5_${r}.txt 
cd ..
done

cd ..
chmod -R a-w homo_sapiens_cifs/

find homo_sapiens_cifs -type f -name \*cif.gz > homo_sapiens.tsv

wc -l homo_sapiens.tsv 
#71249 homo_sapiens.tsv
#	looks like a couple didn't download


~/.local/foldseek/bin/foldseek createdb homo_sapiens.tsv homo_sapiens 

# ?????
#	Ignore 262202 out of 614124.
#	Too short: 261613, incorrect: 0, not proteins: 589.

# increase verbosity if we really want to know what those are


```












https://www.rcsb.org/search?request=%7B%22query%22%3A%7B%22type%22%3A%22group%22%2C%22logical_operator%22%3A%22and%22%2C%22nodes%22%3A%5B%7B%22type%22%3A%22group%22%2C%22logical_operator%22%3A%22and%22%2C%22nodes%22%3A%5B%7B%22type%22%3A%22group%22%2C%22nodes%22%3A%5B%7B%22type%22%3A%22terminal%22%2C%22service%22%3A%22text%22%2C%22parameters%22%3A%7B%22attribute%22%3A%22rcsb_entity_source_organism.taxonomy_lineage.name%22%2C%22operator%22%3A%22exact_match%22%2C%22negation%22%3Afalse%2C%22value%22%3A%22Herpesvirales%22%7D%7D%5D%2C%22logical_operator%22%3A%22and%22%7D%5D%2C%22label%22%3A%22text%22%7D%5D%7D%2C%22return_type%22%3A%22entry%22%2C%22request_options%22%3A%7B%22paginate%22%3A%7B%22start%22%3A0%2C%22rows%22%3A25%7D%2C%22results_content_type%22%3A%5B%22experimental%22%5D%2C%22sort%22%3A%5B%7B%22sort_by%22%3A%22score%22%2C%22direction%22%3A%22desc%22%7D%5D%2C%22scoring_strategy%22%3A%22combined%22%7D%2C%22request_info%22%3A%7B%22query_id%22%3A%22bfe8241cd74170cc8fe826507439d885%22%7D%7D

16VP,1AT3,1B3T,1BU2,1CG9,1CHC,1CM9,1CMV,1CZY,1DML,1E2H,1E2I,1E2J,1E2K,1E2L,1E2M,1E2N,1E2P,1F5Q,1FL1,1G3N,1H15,1HFF,1HFG,1HFN,1HHV,1I1R,1ID4,1IEC,1IED,1IEF,1IEG,1IM3,1JMA,1JOW,1JQ6,1JQ7,1K3K,1K6F,1KG0,1KI2,1KI3,1KI4,1KI6,1KI7,1KI8,1KIM,1L2G,1LAU,1LAY,1LQS,1M05,1MI5,1MKF,1ML0,1NJT,1NJU,1NKK,1NKM,1NO7,1O6E,1OF1,1OSN,1P6X,1P72,1P73,1P75,1P7C,1PQZ,1Q59,1QHI,1QLO,1RJY,1RJZ,1RK0,1RK1,1T0M,1T0N,1T6L,1U58,1UDG,1UDH,1UDI,1URJ,1UXS,1UXW,1VHI,1VLK,1VMP,1VTK,1VYX,1VZV,1WA7,1WPO,1WZB,1X1K,1XO2,1XR8,1Y6M,1Y6N,1YM8,1YY6,1YYP,1ZLA,1ZMS,1ZSD,1ZXT,2ABO,2AK4,2AXF,2AXG,2BSR,2BSY,2BT1,2C36,2C3A,2C53,2C56,2C9L,2C9N,2CH8,2CUO,2D3F,2D3H,2ESV,2EUF,2F2C,2F5U,2F6A,2FHT,2FJ2,2FYY,2FZ3,2GIY,2GJ7,2GUM,2GV9,2H3R,2H6O,2J7Q,2J8X,2JO9,2K2U,2KI5,2KT5,2LQY,2LR1,2MIZ,2MKR,2N2J,2ND0,2NX5,2NYK,2NYZ,2NZ1,2O5N,2OA5,2PBK,2PHE,2PHG,2V6Q,2VTK,2W45,2W4B,2WE0,2WE1,2WE2,2WE3,2WH6,2WPO,2WY3,2X4R,2X4T,2XPX,2XQY,2XXN,2YKA,2YPY,2YPZ,2YQ0,2YQ1,2Z0L,3AH9,3AI6,3AM8,3B0S,3B2C,3BL2,3BVN,3BW9,3BWA,3CL3,3D18,3D2U,3DVU,3DX6,3DX7,3DX8,3DXA,3EYF,3F0T,3FD4,3FHD,3FVC,3GSO,3HSL,3I2M,3KWW,3KXF,3M1C,3MR9,3MRB,3MRC,3MRD,3MRE,3MRF,3MV7,3MV8,3MV9,3N4P,3N4Q,3NJQ,3NW8,3NWA,3NWD,3NWF,3O4L,3PHF,3POV,3RDP,3REW,3SJV,3SKM,3SKO,3SKU,3SPV,3U82,3UEZ,3VCL,3VFN,3VFO,3VFP,3VFR,3VTK,3W9E,3WV0,3X13,3X14,4ADF,4ADQ,4BLG,4BOM,4CX8,4FA8,4G59,4HHA,4HLX,4HLY,4HOB,4HSI,4I9X,4IOX,4IVP,4IVQ,4IVR,4JBX,4JBY,4JM0,4JO8,4JQV,4JQX,4JRX,4JRY,4K2J,4K70,4L1R,4L5N,4MAY,4MI8,4MYV,4MYW,4OQL,4OQM,4OQN,4OQX,4OSN,4OT1,4OYD,4P2T,4P3H,4P55,4PN6,4PR5,4PRA,4PRB,4PRD,4PRE,4PRH,4PRI,4PRN,4PRP,4QRR,4QRS,4QRT,4QRU,4RWS,4TT0,4TT1,4TTH,4U4H,4UZB,4UZC,4V07,4V08,4V0T,4WCG,4WIC,4WID,4WPH,4WPI,4XAL,4XHJ,4XI5,4XSC,4XSD,4XSE,4XT1,4XT3,4YSI,4YXP,4Z3U,4ZKQ,4ZLT,4ZXS,5A3G,5A76,5AYS,5B1Q,5BQK,5C56,5C6T,5CXF,5D2L,5D2N,5D5N,5DOB,5DOC,5DOE,5E5A,5E8C,5ED7,5FKI,5GTC,5H38,5H39,5H3A,5HDA,5HSW,5HUW,5HUY,5IPX,5IWD,5IXA,5J2Z,5KDM,5LDE,5MHJ,5MHK,5NN7,5NNH,5NNU,5SZX,5T1D,5T7X,5TZN,5U1D,5UR3,5UTE,5UTN,5UV3,5UVP,5V2S,5V5D,5V5E,5VKU,5VOB,5VOC,5VOD,5VYL,5W0K,5W1V,5WB1,5WB2,5WMF,5WMO,5WMP,5WMR,5WUM,5WUN,5WX8,5X5V,5X5W,5X8N,5XO2,5YS2,5YS6,5ZAP,5ZB1,5ZB3,5ZS0,5ZZ8,6A4V,6B43,6BM8,6C5V,6CGR,6ESC,6EY7,6FAD,6HAT,6HAU,6JJE,6JJF,6JJG,6JJH,6JJI,6JXU,6JXV,6JXW,6JXX,6K5R,6K5T,6KFL,6LGL,6LGN,6LQN,6LQO,6LS9,6LSA,6LYJ,6LYV,6M5R,6M5S,6M5T,6M5U,6M5V,6M6G,6M6H,6M6I,6NCA,6NHJ,6NPI,6NPM,6NPP,6NYP,6OD7,6ODM,6PPB,6PPD,6PPH,6PPI,6PW2,6Q1F,6Q3K,6QAN,6QBJ,6RVR,6RVS,6SQJ,6T3X,6T3Z,6T5A,6TGZ,6TH1,6TM8,6UOE,6VH6,6VLK,6VMX,6VN1,6W19,6W2D,6W2E,6XF9,6XFA,6XRQ,6Z9M,7B7N,7BCY,7BQT,7BQX,7BR7,7BR8,7BSI,7BW6,7BYF,7CZE,7CZF,7D5Z,7EEB,7ET2,7ET3,7ETJ,7ETM,7ETO,7FBI,7FJ1,7FJ3,7JHJ,7K1S,7K7R,7KBB,7KDD,7KDP,7KE3,7KE5,7LBE,7LBF,7LBG,7LIV,7LJ3,7LUF,7M22,7M30,7NX5,7NXE,7NXP,7NXQ,7NXR,7OPM,7OPO,7P33,7P9W,7PAB,7PDJ,7PDY,7QTW,7QTX,7RAM,7RFP,7RKF,7RKM,7RKN,7RKX,7RKY,7RW6,7S07,7S1B,7SSC,7T4Q,7T4R,7T4S,7T6I,7T7I,7TCZ,7TDQ,7U1T,7UHZ,7UI0,7UKN,7VCL,7VCQ,7WLP,7YOY,7YP1,7YP2,7YRN,7ZJD,7ZJE,7ZJI,7ZN7,7ZNN,8BQ1,8BTJ,8DLF,8ESH,8EXX,8FRT,8G6D,8HEU,8HEV,8HEX,8HEY,8J3S,8J3T,8JF7,8K4O,8K4P,8KFA,8KHR,8OJ6,8OJ7,8OJA,8OJB,8OJC,8OJD,8OSQ,8Q3M,8Q3X,8QDO,8QLN,8QXW,8QXX,8RGZ,8RH0,8RH1,8RH2,8SGN,8SIC,8SM0,8SM1,8SM5,8T1B,8T1C,8T1D,8T1E,8T1F,8TCO,8TEA,8TEP,8TES,8TET,8TEU,8TEW,8TNN,8TNT,8TOO,8UA2,8UA5,8V1Q,8V1R,8V1S,8V1T,8V5L,8V5P,8V5S,8VQ2,8VYM,8VYN,8XH6,8XH7,8Z1E,9DIX,9DIY,9ENP,9ENQ

./batch_download.sh -c -f Herpesvirales.list

646 structures

```

cd ..
~/.local/foldseek/bin/foldseek easy-search Herpesvirales_cifs/*cif.gz homo_sapiens HerpesInHuman.tsv tmpFolder -e 1e-40

~/.local/foldseek/bin/foldseek easy-search Herpesvirales_cifs/*cif.gz homo_sapiens HerpesInHuman.html tmpFolder --format-mode 3 -e 1e-40

 --exhaustive-search 1  ?


echo "<script>function hide_blanks() { var tabs = document.querySelectorAll('div.v-tab'); var emptyTabs = Array.from(tabs).filter(div => div.textContent.includes('(0)')); for (let i = 0; i < emptyTabs.length; i++) { var tmp = emptyTabs[i].style.display = 'None'; }; } window.onload=hide_blanks; </script>" >> HerpesInHuman.html


```





```

https://www.rcsb.org/search?request=%7B%22query%22%3A%7B%22type%22%3A%22group%22%2C%22logical_operator%22%3A%22and%22%2C%22nodes%22%3A%5B%7B%22type%22%3A%22group%22%2C%22logical_operator%22%3A%22and%22%2C%22nodes%22%3A%5B%7B%22type%22%3A%22group%22%2C%22nodes%22%3A%5B%7B%22type%22%3A%22terminal%22%2C%22service%22%3A%22text%22%2C%22parameters%22%3A%7B%22attribute%22%3A%22rcsb_entity_source_organism.taxonomy_lineage.name%22%2C%22operator%22%3A%22exact_match%22%2C%22negation%22%3Afalse%2C%22value%22%3A%22Homo%20sapiens%22%7D%7D%2C%7B%22type%22%3A%22terminal%22%2C%22service%22%3A%22text%22%2C%22parameters%22%3A%7B%22attribute%22%3A%22rcsb_entity_source_organism.taxonomy_lineage.name%22%2C%22operator%22%3A%22exact_match%22%2C%22negation%22%3Afalse%2C%22value%22%3A%22Herpesvirales%22%7D%7D%5D%2C%22logical_operator%22%3A%22and%22%7D%5D%2C%22label%22%3A%22text%22%7D%5D%7D%2C%22return_type%22%3A%22entry%22%2C%22request_options%22%3A%7B%22paginate%22%3A%7B%22start%22%3A0%2C%22rows%22%3A25%7D%2C%22results_content_type%22%3A%5B%22experimental%22%5D%2C%22sort%22%3A%5B%7B%22sort_by%22%3A%22score%22%2C%22direction%22%3A%22desc%22%7D%5D%2C%22scoring_strategy%22%3A%22combined%22%7D%2C%22request_info%22%3A%7B%22query_id%22%3A%224bc60e990909d25e759e172ca4b52992%22%7D%7D

```

233 structures that are both homo sapien and herpesvirales







71018 structures Homo Sapiens NOT Herpesvirales


```
https://www.rcsb.org/search?request=%7B%22query%22%3A%7B%22type%22%3A%22group%22%2C%22logical_operator%22%3A%22and%22%2C%22nodes%22%3A%5B%7B%22type%22%3A%22group%22%2C%22logical_operator%22%3A%22and%22%2C%22nodes%22%3A%5B%7B%22type%22%3A%22group%22%2C%22nodes%22%3A%5B%7B%22type%22%3A%22terminal%22%2C%22service%22%3A%22text%22%2C%22parameters%22%3A%7B%22attribute%22%3A%22rcsb_entity_source_organism.taxonomy_lineage.name%22%2C%22operator%22%3A%22exact_match%22%2C%22negation%22%3Afalse%2C%22value%22%3A%22Homo%20sapiens%22%7D%7D%5D%2C%22logical_operator%22%3A%22and%22%7D%2C%7B%22type%22%3A%22group%22%2C%22nodes%22%3A%5B%7B%22type%22%3A%22terminal%22%2C%22service%22%3A%22text%22%2C%22parameters%22%3A%7B%22attribute%22%3A%22rcsb_entity_source_organism.taxonomy_lineage.name%22%2C%22operator%22%3A%22exact_match%22%2C%22negation%22%3Atrue%2C%22value%22%3A%22Herpesvirales%22%7D%7D%5D%2C%22logical_operator%22%3A%22and%22%7D%5D%2C%22label%22%3A%22text%22%7D%5D%7D%2C%22return_type%22%3A%22entry%22%2C%22request_options%22%3A%7B%22paginate%22%3A%7B%22rows%22%3A100%2C%22start%22%3A600%7D%2C%22results_content_type%22%3A%5B%22experimental%22%5D%2C%22sort%22%3A%5B%7B%22sort_by%22%3A%22score%22%2C%22direction%22%3A%22desc%22%7D%5D%2C%22scoring_strategy%22%3A%22combined%22%7D%2C%22request_info%22%3A%7B%22query_id%22%3A%2247c648785d95390e77bc5aae077c3c90%22%7D%7D

```


```
cd Homo_Sapiens_NOT_Herpesvirales_cifs
for f in rcsb_pdb_ids_*.txt ; do
b=$( basename $f .txt )
echo $b
mkdir $b
cd $b
../../batch_download.sh -c -f ../${f}
cd ..
done

cd ..
chmod -R a-w Homo_Sapiens_NOT_Herpesvirales_cifs/

find Homo_Sapiens_NOT_Herpesvirales_cifs/ -type f -name \*cif.gz > Homo_Sapiens_NOT_Herpesvirales.tsv

wc -l Homo_Sapiens_NOT_Herpesvirales.tsv 
#	71018 Homo_Sapiens_NOT_Herpesvirales.tsv


~/.local/foldseek/bin/foldseek createdb Homo_Sapiens_NOT_Herpesvirales.tsv Homo_Sapiens_NOT_Herpesvirales 

```






413 structures Herpesvirales NOT Homo Sapiens 


```
cd Herpesvirales_NOT_Homo_Sapiens_cifs/
../batch_download.sh -c -f ../Herpesvirales_NOT_Homo_Sapiens.ids
cd ..
~/.local/foldseek/bin/foldseek easy-search Herpesvirales_NOT_Homo_Sapiens_cifs/*cif.gz Homo_Sapiens_NOT_Herpesvirales HerpesInHuman.tsv tmpFolder -e 1e-40
```




