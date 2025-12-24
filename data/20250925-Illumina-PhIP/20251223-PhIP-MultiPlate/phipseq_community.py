#!/usr/bin/env python3

import pandas as pd
import igraph as ig
import sys
from datetime import datetime
import pickle

def log(message):
    """Print timestamped log message"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}", flush=True)

def process_community(comm_id, comm_peptides, filtered_corr, starting_comm_id, resolution=0.01):
    """Process a single BLAST community - can be parallelized"""
    
    # Get correlation edges within this community
    comm_edges = filtered_corr[
        (filtered_corr['source'].isin(comm_peptides)) & 
        (filtered_corr['target'].isin(comm_peptides))
    ].copy()
    
    result = {}
    
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
        subcommunities = subg.community_leiden(weights='weight', resolution=resolution)
        
        # Map back to original peptide IDs
        for i in range(len(subg.vs)):
            peptide_id = unique_peptides[i]
            result[peptide_id] = starting_comm_id + subcommunities.membership[i]
        
        num_subcommunities = len(subcommunities)
    else:
        # No correlations - each peptide is its own community
        for idx, peptide in enumerate(comm_peptides):
            result[peptide] = starting_comm_id + idx
        num_subcommunities = len(comm_peptides)
    
    return result, num_subcommunities

# Main script
log("Starting PhipSeq community detection")

# Load master peptide list
log("Loading master peptide list...")
master_peptides_df = pd.read_csv("/francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_upper_peptide.uniq.csv", 
                                  header=None, names=['peptide_id', 'sequence'])
actual_peptides = sorted(master_peptides_df['peptide_id'].unique())
log(f"Master peptide list: {len(actual_peptides)} peptides")
log(f"Peptide ID range: {min(actual_peptides)} to {max(actual_peptides)}")

# Load BLAST edges
log("Loading BLAST edges...")
reference_edges_df = pd.read_csv("edgelist.csv.gz")
log(f"Loaded {len(reference_edges_df)} BLAST edges")

blast_peptides = set(reference_edges_df['source']) | set(reference_edges_df['target'])
log(f"Unique peptides in BLAST: {len(blast_peptides)}")
log(f"Peptides in master but not in BLAST: {len(set(actual_peptides) - blast_peptides)}")

# Create mapping: original peptide ID -> sequential index (0-based)
# Only for peptides that appear in BLAST
blast_peptides_sorted = sorted(blast_peptides)
peptide_to_idx = {peptide: idx for idx, peptide in enumerate(blast_peptides_sorted)}
idx_to_peptide = {idx: peptide for peptide, idx in peptide_to_idx.items()}

# Remap edges to use sequential indices
reference_edges_df['source_idx'] = reference_edges_df['source'].map(peptide_to_idx)
reference_edges_df['target_idx'] = reference_edges_df['target'].map(peptide_to_idx)

# Get BLAST-based communities
log("Running Leiden on BLAST graph...")
g = ig.Graph.DataFrame(
    edges=reference_edges_df[['source_idx', 'target_idx', 'weight']].rename(
        columns={'source_idx': 'source', 'target_idx': 'target'}
    ),
    directed=True
)
blast_communities = g.community_leiden(weights='weight', resolution=1.0)
log(f"BLAST clustering: {len(blast_communities)} communities from {len(g.vs)} peptides")

# Create mapping: actual peptide_id -> community, using idx_to_peptide
peptide_to_community = {}
for i in range(len(g.vs)):
    peptide_id = idx_to_peptide[i]
    peptide_to_community[peptide_id] = blast_communities.membership[i]

# Handle peptides not in BLAST - assign them each to a singleton community
peptides_not_in_blast = set(actual_peptides) - set(peptide_to_community.keys())
if len(peptides_not_in_blast) > 0:
    log(f"Assigning {len(peptides_not_in_blast)} peptides without BLAST edges to singleton communities")
    next_comm_id = len(blast_communities)
    for peptide_id in sorted(peptides_not_in_blast):
        peptide_to_community[peptide_id] = next_comm_id
        next_comm_id += 1

# Load correlations
log("Loading correlation edges...")
correlations_df = pd.read_csv("out.123456131415161718/zscore.filtered.threshold5.correlation_edges.csv.gz")
log(f"Loaded {len(correlations_df)} correlation edges")

correlations_df = correlations_df[correlations_df['weight'] > 0]
log(f"After filtering positive correlations: {len(correlations_df)} edges")

# Map communities for source and target
log("Filtering correlations to within-BLAST-community pairs...")
correlations_df['source_comm'] = correlations_df['source'].map(peptide_to_community)
correlations_df['target_comm'] = correlations_df['target'].map(peptide_to_community)

# Filter to within-community pairs
filtered_corr = correlations_df[
    correlations_df['source_comm'] == correlations_df['target_comm']
].drop(columns=['source_comm', 'target_comm'])
log(f"Within-community correlation edges: {len(filtered_corr)}")

# Process each BLAST community
log(f"Processing {len(blast_communities)} BLAST communities...")
final_communities = {}
community_id = 0

# Get size distribution of BLAST communities
blast_sizes = [sum(1 for m in blast_communities.membership if m == i) 
               for i in range(len(blast_communities))]
log(f"BLAST community sizes - min: {min(blast_sizes)}, max: {max(blast_sizes)}, "
    f"median: {sorted(blast_sizes)[len(blast_sizes)//2]}")

# Process communities with progress logging
for comm_id in range(len(blast_communities)):
    if comm_id % 100 == 0:
        log(f"Processing BLAST community {comm_id}/{len(blast_communities)} "
            f"({100*comm_id/len(blast_communities):.1f}%) - "
            f"Total subcommunities so far: {community_id}")
    
    # Get peptides in this BLAST community
    comm_peptides = [peptide_id for peptide_id, c_id in peptide_to_community.items() if c_id == comm_id]
    
    # Process this community
    result, num_subcommunities = process_community(
        comm_id, comm_peptides, filtered_corr, community_id, resolution=0.01
    )
    
    final_communities.update(result)
    community_id += num_subcommunities

log(f"Final number of communities: {community_id}")

# Save results
log("Saving results...")

# Save as CSV
output_df = pd.DataFrame([
    {'peptide_id': peptide, 'community_id': comm} 
    for peptide, comm in sorted(final_communities.items())
])
output_df.to_csv('final_communities.csv', index=False)
log(f"Saved community assignments to final_communities.csv")

# Also save as pickle for quick reloading
with open('final_communities.pkl', 'wb') as f:
    pickle.dump(final_communities, f)
log(f"Saved community dictionary to final_communities.pkl")

# Print summary statistics
community_sizes = {}
for peptide, comm in final_communities.items():
    community_sizes[comm] = community_sizes.get(comm, 0) + 1

sizes = sorted(community_sizes.values())
log(f"Final community statistics:")
log(f"  Total communities: {len(community_sizes)}")
log(f"  Peptides assigned: {len(final_communities)}")
log(f"  Community sizes - min: {min(sizes)}, max: {max(sizes)}, median: {sizes[len(sizes)//2]}")
log(f"  Singletons: {sum(1 for s in sizes if s == 1)}")

log("Complete!")

