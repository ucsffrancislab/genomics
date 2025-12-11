#!/usr/bin/env python3

"""
Parallel version of PhipSeq community detection
Usage:
  Step 1: phipseq_parallel.py prepare
  Step 2: sbatch array job (see generate_slurm_script())
  Step 3: phipseq_parallel.py merge
"""

import pandas as pd
import igraph as ig
import sys
import pickle
from pathlib import Path
from datetime import datetime
import numpy as np

def log(message):
    """Print timestamped log message"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}", flush=True)

def prepare_data():
    """Step 1: Prepare data for parallel processing"""
    log("Starting data preparation...")
    
    # Load BLAST edges
    log("Loading BLAST edges...")
    #reference_edges_df = pd.read_csv("edgelist.csv")				#				<-- this is from blasting peptides to themselves
    reference_edges_df = pd.read_csv("edgelist.word_size-2.csv.gz")				#				<-- this is from blasting peptides to themselves
    # head edgelist.csv 
    # query,target,weight
    # 1,76530,53.5
    # 1,42970,38.9
    # 1,19604,37.4
    # 1,19599,35.0
    # 1,2,30.0
    # 1,120610,24.3
    # 2,3,57.4
    log(f"Loaded {len(reference_edges_df)} BLAST edges")
    
    # Get BLAST-based communities
    log("Running Leiden on BLAST graph...")
    g = ig.Graph.DataFrame(edges=reference_edges_df, directed=True)
    blast_communities = g.community_leiden(weights='weight', resolution=1.0)
    log(f"BLAST clustering: {len(blast_communities)} communities from {len(g.vs)} peptides")
    
    # Create mapping: peptide_id = vertex_index + 1
    peptide_to_community = {i + 1: blast_communities.membership[i] for i in range(len(g.vs))}
    
    # Create list of peptides per BLAST community
    blast_comm_peptides = {}
    for i in range(len(g.vs)):
        comm_id = blast_communities.membership[i]
        peptide_id = i + 1
        if comm_id not in blast_comm_peptides:
            blast_comm_peptides[comm_id] = []
        blast_comm_peptides[comm_id].append(peptide_id)





#    # ADD THIS FOR TESTING - only keep first 100 communities
#    log(f"TESTING MODE: Limiting to first 100 BLAST communities")
#    all_comm_ids = sorted(blast_comm_peptides.keys())
#    blast_comm_peptides = {k: blast_comm_peptides[k] for k in all_comm_ids[:100]}





    
    # Load correlations
    log("Loading correlation edges...")
    #correlations_df = pd.read_csv("out.123456131415161718/correlation_edges.csv.gz")	# <--- this is from running correlations.py
    correlations_df = pd.read_csv("out.123456131415161718/zscore.correlation_edges.csv.gz")	# <--- this is from running correlations.py
    #
    # It is the pairwise correlations save in an undirected list with just abs(corr) > 0.3
    #
    # the latest version is completely unfiltered
    #
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
    ][['source', 'target', 'weight', 'source_comm']]
    log(f"Within-community correlation edges: {len(filtered_corr)}")
    
    # Save prepared data
    output_dir = Path("parallel_work")
    output_dir.mkdir(exist_ok=True)
    
    with open(output_dir / "blast_comm_peptides.pkl", 'wb') as f:
        pickle.dump(blast_comm_peptides, f)
    
    filtered_corr.to_parquet(output_dir / "filtered_correlations.parquet")
    
    log(f"Saved prepared data to {output_dir}/")
    log(f"Total BLAST communities to process: {len(blast_comm_peptides)}")
    
    return len(blast_comm_peptides)

#def process_batch(batch_id, num_batches, resolution=0.01):
#    """Step 2: Process a batch of BLAST communities"""
#    log(f"Starting batch {batch_id}/{num_batches}")
#    
#    output_dir = Path("parallel_work")
#    
#    # Load prepared data
#    with open(output_dir / "blast_comm_peptides.pkl", 'rb') as f:
#        blast_comm_peptides = pickle.load(f)
#    
#    filtered_corr = pd.read_parquet(output_dir / "filtered_correlations.parquet")
#    
#    # Determine which communities this batch processes
#    all_comm_ids = sorted(blast_comm_peptides.keys())
#    batch_size = len(all_comm_ids) // num_batches + 1
#    start_idx = batch_id * batch_size
#    end_idx = min((batch_id + 1) * batch_size, len(all_comm_ids))
#    my_comm_ids = all_comm_ids[start_idx:end_idx]
#    
#    log(f"Batch {batch_id} processing communities {start_idx} to {end_idx-1} ({len(my_comm_ids)} communities)")
#    
#    batch_results = []
#    
#    for idx, comm_id in enumerate(my_comm_ids):
#        if idx % 10 == 0:
#            log(f"Batch {batch_id}: Processing {idx}/{len(my_comm_ids)} ({100*idx/len(my_comm_ids):.1f}%)")
#        
#    #    comm_peptides = blast_comm_peptides[comm_id]
#    #    
#    #    # Get correlation edges within this community
#    #    comm_edges = filtered_corr[filtered_corr['source_comm'] == comm_id][['source', 'target', 'weight']].copy()
#    #    
#    #    if len(comm_edges) > 0:
#    #        # Get unique peptides and create a mapping to 0-based indices
#    #        unique_peptides = sorted(set(comm_edges['source']) | set(comm_edges['target']))
#    #        peptide_to_idx = {peptide: idx for idx, peptide in enumerate(unique_peptides)}
#    #        
#    #        # Remap edges to 0-based indices
#    #        comm_edges['source_idx'] = comm_edges['source'].map(peptide_to_idx)
#    #        comm_edges['target_idx'] = comm_edges['target'].map(peptide_to_idx)
#    #        
#    #        # Create subgraph with remapped indices
#    #        subg = ig.Graph.DataFrame(
#    #            edges=comm_edges[['source_idx', 'target_idx', 'weight']].rename(
#    #                columns={'source_idx': 'source', 'target_idx': 'target'}
#    #            ),
#    #            directed=False
#    #        )
#    #        subcommunities = subg.community_leiden(weights='weight', resolution=resolution)
#    #        
#    #        # Store results for this BLAST community
#    #        for i in range(len(subg.vs)):
#    #            peptide_id = unique_peptides[i]
#    #            subcomm_id = subcommunities.membership[i]
#    #            batch_results.append({
#    #                'blast_comm': comm_id,
#    #                'peptide_id': peptide_id,
#    #                'subcomm_id': subcomm_id
#    #            })
#    #    else:
#    #        # No correlations - each peptide is its own community
#    #        for subcomm_id, peptide in enumerate(comm_peptides):
#    #            batch_results.append({
#    #                'blast_comm': comm_id,
#    #                'peptide_id': peptide,
#    #                'subcomm_id': subcomm_id
#    #            })
#
#    comm_peptides = blast_comm_peptides[comm_id]
#    
#    # Get correlation edges within this community
#    comm_edges = filtered_corr[filtered_corr['source_comm'] == comm_id][['source', 'target', 'weight']].copy()
#    
#    # Get peptides that have correlation edges within this community
#    peptides_with_edges = set(comm_edges['source']) | set(comm_edges['target']) if len(comm_edges) > 0 else set()
#    
#    if len(peptides_with_edges) > 1:
#        # Cluster peptides with correlation edges
#        unique_peptides = sorted(peptides_with_edges)
#        peptide_to_idx = {peptide: idx for idx, peptide in enumerate(unique_peptides)}
#        
#        # Remap edges to 0-based indices
#        comm_edges['source_idx'] = comm_edges['source'].map(peptide_to_idx)
#        comm_edges['target_idx'] = comm_edges['target'].map(peptide_to_idx)
#        
#        # Create subgraph with remapped indices
#        subg = ig.Graph.DataFrame(
#            edges=comm_edges[['source_idx', 'target_idx', 'weight']].rename(
#                columns={'source_idx': 'source', 'target_idx': 'target'}
#            ),
#            directed=False
#        )
#        subcommunities = subg.community_leiden(weights='weight', resolution=resolution)
#        
#        # Store results for peptides with edges
#        for i in range(len(subg.vs)):
#            peptide_id = unique_peptides[i]
#            subcomm_id = subcommunities.membership[i]
#            batch_results.append({
#                'blast_comm': comm_id,
#                'peptide_id': peptide_id,
#                'subcomm_id': subcomm_id
#            })
#        
#        # Add peptides WITHOUT edges in this community as singletons
#        peptides_without_edges = set(comm_peptides) - peptides_with_edges
#        next_subcomm_id = len(subcommunities)
#        for idx, peptide in enumerate(sorted(peptides_without_edges)):
#            batch_results.append({
#                'blast_comm': comm_id,
#                'peptide_id': peptide,
#                'subcomm_id': next_subcomm_id + idx
#            })
#    else:
#        # No edges or only 1 peptide with edges - all peptides are singletons
#        for subcomm_id, peptide in enumerate(sorted(comm_peptides)):
#            batch_results.append({
#                'blast_comm': comm_id,
#                'peptide_id': peptide,
#                'subcomm_id': subcomm_id
#            })
#    
#    # Save batch results
#    batch_df = pd.DataFrame(batch_results)
#    batch_df.to_parquet(output_dir / f"batch_{batch_id:04d}.parquet")
#    log(f"Batch {batch_id} complete: {len(batch_df)} peptides assigned")






def process_batch(batch_id, num_batches, resolution=0.01):
    """Step 2: Process a batch of BLAST communities"""
    log(f"Starting batch {batch_id}/{num_batches}")
    
    output_dir = Path("parallel_work")
    
    # Load prepared data
    with open(output_dir / "blast_comm_peptides.pkl", 'rb') as f:
        blast_comm_peptides = pickle.load(f)
    
    filtered_corr = pd.read_parquet(output_dir / "filtered_correlations.parquet")
    
    # Determine which communities this batch processes
    all_comm_ids = sorted(blast_comm_peptides.keys())
    batch_size = len(all_comm_ids) // num_batches + 1
    start_idx = batch_id * batch_size
    end_idx = min((batch_id + 1) * batch_size, len(all_comm_ids))
    my_comm_ids = all_comm_ids[start_idx:end_idx]
    
    log(f"Batch {batch_id} processing communities {start_idx} to {end_idx-1} ({len(my_comm_ids)} communities)")
    
    batch_results = []
    
    for idx, comm_id in enumerate(my_comm_ids):
        if idx % 10 == 0:
            log(f"Batch {batch_id}: Processing {idx}/{len(my_comm_ids)} ({100*idx/len(my_comm_ids):.1f}%)")
        
        # ALL peptides in this BLAST community
        comm_peptides = blast_comm_peptides[comm_id]
        
        # Get correlation edges within this community (might be empty for most!)
        comm_edges = filtered_corr[filtered_corr['source_comm'] == comm_id][['source', 'target', 'weight']].copy()
        
        # Peptides that have edges
        peptides_with_edges = set(comm_edges['source']) | set(comm_edges['target']) if len(comm_edges) > 0 else set()
        
        if len(peptides_with_edges) > 1:
            # Cluster peptides that have edges
            unique_peptides = sorted(peptides_with_edges)
            peptide_to_idx = {peptide: idx for idx, peptide in enumerate(unique_peptides)}
            
            comm_edges['source_idx'] = comm_edges['source'].map(peptide_to_idx)
            comm_edges['target_idx'] = comm_edges['target'].map(peptide_to_idx)
            
            subg = ig.Graph.DataFrame(
                edges=comm_edges[['source_idx', 'target_idx', 'weight']].rename(
                    columns={'source_idx': 'source', 'target_idx': 'target'}
                ),
                directed=False
            )
            subcommunities = subg.community_leiden(weights='weight', resolution=resolution)
            
            # Assign clustered peptides
            for i in range(len(subg.vs)):
                peptide_id = unique_peptides[i]
                subcomm_id = subcommunities.membership[i]
                batch_results.append({
                    'blast_comm': comm_id,
                    'peptide_id': peptide_id,
                    'subcomm_id': subcomm_id
                })
            
            # CRITICAL: Assign peptides WITHOUT edges as singletons
            peptides_without_edges = set(comm_peptides) - peptides_with_edges
            next_subcomm_id = len(subcommunities)
            for local_idx, peptide in enumerate(sorted(peptides_without_edges)):
                batch_results.append({
                    'blast_comm': comm_id,
                    'peptide_id': peptide,
                    'subcomm_id': next_subcomm_id + local_idx
                })
        else:
            # No edges or only 1 peptide with edges - ALL peptides are singletons
            for subcomm_id, peptide in enumerate(sorted(comm_peptides)):
                batch_results.append({
                    'blast_comm': comm_id,
                    'peptide_id': peptide,
                    'subcomm_id': subcomm_id
                })
    
    # Save batch results
    batch_df = pd.DataFrame(batch_results)
    batch_df.to_parquet(output_dir / f"batch_{batch_id:04d}.parquet")
    log(f"Batch {batch_id} complete: {len(batch_df)} peptides assigned")




def merge_results():
    """Step 3: Merge all batch results"""
    log("Merging batch results...")
    
    output_dir = Path("parallel_work")
    batch_files = sorted(output_dir.glob("batch_*.parquet"))
    
    log(f"Found {len(batch_files)} batch files")
    
    all_results = []
    for batch_file in batch_files:
        df = pd.read_parquet(batch_file)
        all_results.append(df)
    
    combined = pd.concat(all_results, ignore_index=True)
    log(f"Total peptides: {len(combined)}")
    
    # Assign global community IDs
    # Sort by blast_comm, then by subcomm_id to ensure consistent ordering
    combined = combined.sort_values(['blast_comm', 'subcomm_id'])
    
    # Create unique community IDs
    combined['temp_id'] = combined['blast_comm'].astype(str) + '_' + combined['subcomm_id'].astype(str)
    unique_communities = {comm: idx for idx, comm in enumerate(combined['temp_id'].unique())}
    combined['final_comm_id'] = combined['temp_id'].map(unique_communities)
    
    # Create final output
    final_output = combined[['peptide_id', 'final_comm_id']].rename(
        columns={'final_comm_id': 'community_id'}
    ).sort_values('peptide_id')
    
    # Save results
    final_output.to_csv('final_communities.csv', index=False)
    log(f"Saved community assignments to final_communities.csv")
    
    # Also save as dictionary pickle
    final_dict = dict(zip(final_output['peptide_id'], final_output['community_id']))
    with open('final_communities.pkl', 'wb') as f:
        pickle.dump(final_dict, f)
    log(f"Saved community dictionary to final_communities.pkl")
    
    # Print summary statistics
    community_sizes = final_output['community_id'].value_counts()
    log(f"\nFinal community statistics:")
    log(f"  Total communities: {len(community_sizes)}")
    log(f"  Peptides assigned: {len(final_output)}")
    log(f"  Community sizes - min: {community_sizes.min()}, max: {community_sizes.max()}, median: {community_sizes.median():.0f}")
    log(f"  Singletons: {(community_sizes == 1).sum()}")
    
    log("Complete!")

def generate_slurm_script(num_batches=100):
    """Generate a SLURM array job script"""
    script = f"""#!/bin/bash
#SBATCH --job-name=phipseq_comm
#SBATCH --array=0-{num_batches-1}
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=4:00:00
#SBATCH --output=parallel_work/batch_%a.log

# Load your Python environment here
# module load python
# source activate myenv

phipseq_parallel.py process $SLURM_ARRAY_TASK_ID {num_batches}
"""
    
    with open("run_parallel.sh", 'w') as f:
        f.write(script)
    
    log(f"Generated SLURM script: run_parallel.sh")
    log(f"Submit with: sbatch run_parallel.sh")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage:")
        print("  phipseq_parallel.py prepare [num_batches]")
        print("  phipseq_parallel.py process <batch_id> <num_batches>")
        print("  phipseq_parallel.py merge")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "prepare":
        num_communities = prepare_data()
        num_batches = int(sys.argv[2]) if len(sys.argv) > 2 else 100
        generate_slurm_script(num_batches)
        log(f"\nNext steps:")
        log(f"  1. Submit job: sbatch run_parallel.sh")
        log(f"  2. After jobs complete: phipseq_parallel.py merge")
    
    elif command == "process":
        batch_id = int(sys.argv[2])
        num_batches = int(sys.argv[3])
        #process_batch(batch_id, num_batches)
        process_batch(batch_id, num_batches, resolution=0.001) # decreasing resolution to try to create fewer, larger communities
    
    elif command == "merge":
        merge_results()
    
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)
