
from phippery.utils import dataset_from_csv

import phippery
ds = dataset_from_csv(
    'formatted_data/peptide_table.csv',
    'formatted_data/sample_table.csv', 
    'formatted_data/counts_matrix.csv'
)
phippery.dump(ds, 'dataset.phip')
print('Done!')
print(ds)

#	The code for load-from-csv has a bug. The above does what that function should.
#	singularity exec containers/phippery.sif phippery load-from-csv -c formatted_data/counts_matrix.csv -p formatted_data/peptide_table.csv -s formatted_data/sample_table.csv -o dataset.phip

