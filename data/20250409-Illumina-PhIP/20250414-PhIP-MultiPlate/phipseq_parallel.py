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
    
    # Save the actual peptide list
    output_dir = Path("parallel_work")
    output_dir.mkdir(exist_ok=True)
    
    with open(output_dir / "actual_peptides.pkl", 'wb') as f:
        pickle.dump(set(actual_peptides), f)
    
    # Create mapping: original peptide ID -> sequential index (0-based)
    # Only for peptides that appear in BLAST
    blast_peptides_sorted = sorted(blast_peptides)
    peptide_to_idx = {peptide: idx for idx, peptide in enumerate(blast_peptides_sorted)}
    idx_to_peptide = {idx: peptide for peptide, idx in peptide_to_idx.items()}
    
    # Remap BLAST edges to use sequential indices
    reference_edges_df['source_idx'] = reference_edges_df['source'].map(peptide_to_idx)
    reference_edges_df['target_idx'] = reference_edges_df['target'].map(peptide_to_idx)
    
    # Get BLAST-based communities using remapped edges
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
    
    # Create list of peptides per BLAST community
    blast_comm_peptides = {}
    for peptide_id, comm_id in peptide_to_community.items():
        if comm_id not in blast_comm_peptides:
            blast_comm_peptides[comm_id] = []
        blast_comm_peptides[comm_id].append(peptide_id)
    
    # Load correlations
    log("Loading correlation edges...")
    correlations_df = pd.read_csv("out.123456131415161718/zscore.correlation_edges.csv.gz")
    log(f"Loaded {len(correlations_df)} correlation edges")
    
    # Filter correlations to only actual peptides
    correlations_df = correlations_df[
        correlations_df['source'].isin(actual_peptides) &
        correlations_df['target'].isin(actual_peptides)
    ]
    log(f"After filtering to actual peptides: {len(correlations_df)} edges")
    
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
    with open(output_dir / "blast_comm_peptides.pkl", 'wb') as f:
        pickle.dump(blast_comm_peptides, f)
    
    # Also save the full peptide_to_community mapping
    with open(output_dir / "peptide_to_community.pkl", 'wb') as f:
        pickle.dump(peptide_to_community, f)
    
    filtered_corr.to_parquet(output_dir / "filtered_correlations.parquet")
    
    log(f"Saved prepared data to {output_dir}/")
    log(f"Total BLAST communities to process: {len(blast_comm_peptides)}")
    log(f"Total peptides with community assignments: {len(peptide_to_community)}")
    
    return len(blast_comm_peptides)

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
    
    # Load actual peptides
    with open(output_dir / "actual_peptides.pkl", 'rb') as f:
        actual_peptides = pickle.load(f)
    log(f"Actual peptides in dataset: {len(actual_peptides)}")
    
    batch_files = sorted(output_dir.glob("batch_*.parquet"))
    
    log(f"Found {len(batch_files)} batch files")
    
    all_results = []
    for batch_file in batch_files:
        df = pd.read_parquet(batch_file)
        all_results.append(df)
    
    combined = pd.concat(all_results, ignore_index=True)
    log(f"Total peptides from batch processing: {len(combined)}")
    
    # Load the full peptide_to_community mapping to find missing peptides
    with open(output_dir / "peptide_to_community.pkl", 'rb') as f:
        peptide_to_community = pickle.load(f)
    
    # Find peptides that didn't get processed (singleton BLAST communities with no correlations)
    processed_peptides = set(combined['peptide_id'])
    missing_peptides = set(peptide_to_community.keys()) - processed_peptides
    
    if len(missing_peptides) > 0:
        log(f"Found {len(missing_peptides)} peptides not in batch results - adding them as singletons")
        
        # Get their BLAST community IDs
        missing_rows = []
        for peptide_id in missing_peptides:
            missing_rows.append({
                'blast_comm': peptide_to_community[peptide_id],
                'peptide_id': peptide_id,
                'subcomm_id': 0  # They're singletons in their BLAST community
            })
        
        missing_df = pd.DataFrame(missing_rows)
        combined = pd.concat([combined, missing_df], ignore_index=True)
        log(f"Total peptides after adding missing: {len(combined)}")
    
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
    
    # Verify all output peptides are actual peptides
    invalid_peptides = set(final_output['peptide_id']) - actual_peptides
    if len(invalid_peptides) > 0:
        log(f"WARNING: Found {len(invalid_peptides)} invalid peptide IDs, removing them")
        final_output = final_output[final_output['peptide_id'].isin(actual_peptides)]
    
    log(f"Final output contains {len(final_output)} peptides (expected {len(actual_peptides)})")
    
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
    log(f"Final community statistics:")
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
        process_batch(batch_id, num_batches)
    
    elif command == "merge":
        merge_results()
    
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)

