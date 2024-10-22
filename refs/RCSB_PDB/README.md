
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



