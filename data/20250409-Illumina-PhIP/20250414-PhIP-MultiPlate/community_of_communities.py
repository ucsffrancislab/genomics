#!/usr/bin/env python3

import pandas as pd
import igraph as ig

reference_edges_df = pd.read_csv("edgelist.csv")

# Get BLAST-based communities
g = ig.Graph.DataFrame(edges=reference_edges_df, directed=True)
blast_communities = g.community_leiden(weights='weight', resolution=1.0)

# Create mapping: peptide_id = vertex_index + 1
peptide_to_community = {i + 1: blast_communities.membership[i] for i in range(len(g.vs))}

correlations_df = pd.read_csv("out.123456131415161718/correlation_edges.csv.gz")
correlations_df = correlations_df[correlations_df['weight'] > 0]

# Map communities for source and target
correlations_df['source_comm'] = correlations_df['source'].map(peptide_to_community)
correlations_df['target_comm'] = correlations_df['target'].map(peptide_to_community)

# Filter to within-community pairs
filtered_corr = correlations_df[
    correlations_df['source_comm'] == correlations_df['target_comm']
].drop(columns=['source_comm', 'target_comm'])


# Now run Leiden on each community's correlation subgraph
final_communities = {}
community_id = 0

for comm_id in range(len(blast_communities)):
    # Get peptides in this BLAST community (add 1 to convert from 0-based vertex index to 1-based peptide ID)
    comm_peptides = [i + 1 for i in range(len(g.vs)) 
                     if blast_communities.membership[i] == comm_id]
    
    # Get correlation edges within this community
    comm_edges = filtered_corr[
        (filtered_corr['source'].isin(comm_peptides)) & 
        (filtered_corr['target'].isin(comm_peptides))
    ].copy()
    
    if len(comm_edges) > 0:
        # Get unique peptides and create a mapping to 0-based indices
        unique_peptides = sorted(set(comm_edges['source']) | set(comm_edges['target']))
        peptide_to_idx = {peptide: idx for idx, peptide in enumerate(unique_peptides)}
        
        # Remap edges to 0-based indices
        comm_edges['source_idx'] = comm_edges['source'].map(peptide_to_idx)
        comm_edges['target_idx'] = comm_edges['target'].map(peptide_to_idx)
        
        # Create subgraph with remapped indices
        subg = ig.Graph.DataFrame(
            edges=comm_edges[['source_idx', 'target_idx', 'weight']].rename(
                columns={'source_idx': 'source', 'target_idx': 'target'}
            ),
            directed=False
        )
        subcommunities = subg.community_leiden(weights='weight', resolution=0.01)
        
        # Map back to original peptide IDs
        for i in range(len(subg.vs)):
            peptide_id = unique_peptides[i]
            final_communities[peptide_id] = community_id + subcommunities.membership[i]
        
        community_id += len(subcommunities)
    else:
        # No correlations - each peptide is its own community
        for peptide in comm_peptides:
            final_communities[peptide] = community_id
            community_id += 1

print(f"Final number of communities: {community_id}")


#	First version of using alignement count correlations on blast correlations
# Tried running this on my laptop and it was still going after about 60 hours.
#	Claude wrote a parellelized version.


