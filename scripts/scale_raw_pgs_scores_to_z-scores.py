#!/usr/bin/env python3

#	https://claude.ai/chat/c69f3de2-617c-4d51-b008-a16805d0dfb6

import argparse
import pandas as pd
from scipy.stats import zscore


def zscore_prs(input_file, output_file):
    """Convert raw PRS scores to z-scores by column."""
    df = pd.read_csv(input_file, index_col='sample')
    df_zscore = df.apply(zscore, axis=0)
    df_zscore.to_csv(output_file)
    print(f"Z-scored PRS written to {output_file}")


def test_zscore_prs():
    """Quick smoke test with known input/output."""
    import tempfile
    import numpy as np
    import os
    
    # Create test input
    test_data = "sample,PGS1,PGS2\nS1,1,2\nS2,2,4\nS3,3,6\n"
    
    with tempfile.NamedTemporaryFile(mode='w', suffix='.csv', delete=False) as f:
        f.write(test_data)
        input_file = f.name
    
    output_file = input_file.replace('.csv', '_out.csv')
    
    try:
        zscore_prs(input_file, output_file)
        
        # Read result and verify means ~0, stds ~1
        result = pd.read_csv(output_file, index_col='sample')
        assert np.allclose(result.mean(), 0, atol=1e-10), "Column means should be ~0"
        assert np.allclose(result.std(ddof=0), 1, atol=1e-10), "Column stds should be ~1"
        
        print("✓ All tests passed")
    finally:
        # Cleanup temp files
        if os.path.exists(input_file):
            os.unlink(input_file)
        if os.path.exists(output_file):
            os.unlink(output_file)


if __name__ == '__main__':
    import sys
    
    if '--test' in sys.argv:
        test_zscore_prs()
    else:
        parser = argparse.ArgumentParser(
            description='Convert raw PRS scores to z-scores by column (PGS model)'
        )
        parser.add_argument(
            '-i', '--input',
            required=True,
            help='Input CSV file with raw PRS scores'
        )
        parser.add_argument(
            '-o', '--output',
            required=True,
            help='Output CSV file for z-scored PRS'
        )
        
        args = parser.parse_args()
        zscore_prs(args.input, args.output)


