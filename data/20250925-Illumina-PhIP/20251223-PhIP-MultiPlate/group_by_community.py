#!/usr/bin/env python3

import sys
import pandas as pd

df=pd.read_csv(sys.argv[1], header=[0,1,2], index_col=[0,1,2])

df.index.names=['peptide','community','species']

df.columns.names=['subject','type','sample']

df.groupby(['community'], dropna=False).median().to_csv(sys.stdout, index_label=False)

