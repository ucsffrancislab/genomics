#!/usr/bin/env python3

import os
import asyncio
from edison_client import EdisonClient
from edison_client import JobNames
from edison_client import TaskRequest
from edison_client.models import RuntimeConfig
#from ldp.agent import AgentConfig

with open("/c4/home/gwendt/EDISON_API_TOKEN", 'r') as file:
	api_key = file.read()

api_key = api_key.rstrip()	# Cannot include a carriage return
print(api_key)

client = EdisonClient(api_key=api_key)
print("Set client")


#	https://edisonscientific.gitbook.io/edison-cookbook/edison-client/docs/edison_analysis_tutorial

async def upload():
	print("Uploading", flush=True)
	# Uploading a directory to the data storage service
	response = await client.astore_file_content(
    	name="Directory containing the cidr/i370/onco/tcga covariates",
    	file_path="./edison_prs_survival_analysis",  # ADD DATASET FOLDER PATH HERE
    	description="This is a directory that will be be analysed by Edison Analysis",
    	as_collection=True,
	)
	print("Finished Uploading", flush=True)
	return response

directory_upload_response = asyncio.run(upload())



query = """
Included in the provided directory data from 4 different datasets (cidr,i370,onco,tcga).
Each dataset was genotyped separately on a different SNP array.
Each dataset was then imputed separately on the UMich imputation servers.
Each dataset was then lifted over to hg38, filtered with R2>0.8 and normalized.
These vcf files were then scored against the majority of the PGS catalog plus 7 additional custom models using pgs-calc.
pgs-calc generated a DATASET.scores.info file that contains a variety of data from the scoring of each model.
Each dataset then had its scores scaled generating the DATASET.scores.z-scores.txt.gz file.
In addition each dataset has a set of covariates in DATASET-covariates.tsv.

For each dataset, using all appropriate covariates run a survival analysis Cox models for ...
* all cases
* all IDH wildtype (idh=0) cases
* all IDH mutant (idh=1) cases
* all HGG IDH wildtype (grade=HGG, idh=0) cases
* all HGG IDH mutant (grade=HGG, idh=1) cases
* all LGG IDH wildtype (grade=LGG, idh=0) cases
* all LGG IDH mutant (grade=LGG, idh=1) cases
* all LGG IDH mutant 1p19q intact (grade=LGG, idh=1, pq=0) cases
* all LGG IDH mutant 1p19q codel (grade=LGG, idh=1, pq=1) cases

Produce tables of the top associations by model and subset.
After completion, combine all 4 datasets using METAL or something like METAL.
Produce volcano plots for each model, forest plots and multi-dataset Kaplan-Meier Comparison plots for top meta-analysis hits
"""

# Create a task
task_data = TaskRequest(
    name=JobNames.ANALYSIS,
    query=query,
    runtime_config=RuntimeConfig(
        environment_config={
            "language": "PYTHON",
            "data_storage_uris": [
                f"data_entry:{directory_upload_response.data_storage.id}"
            ],
        },
    ),
)
trajectory_id = client.create_task(task_data)
print(
    f"Task running on platform, you can view progress live at:https://platform.edisonscientific.com/trajectories/{trajectory_id}"
)


"""

./normalize_covariates.bash cidr pgs-calc-scores-merged/cidr/cidr-covariates.tsv > edison_prs_survival_analysis/cidr-covariates.tsv
./normalize_covariates.bash i370 pgs-calc-scores-merged/i370/i370-covariates.tsv > edison_prs_survival_analysis/i370-covariates.tsv
./normalize_covariates.bash onco pgs-calc-scores-merged/onco/onco-covariates.tsv > edison_prs_survival_analysis/onco-covariates.tsv
./normalize_covariates.bash tcga pgs-calc-scores-merged/tcga/tcga-covariates.tsv > edison_prs_survival_analysis/tcga-covariates.tsv

for d in cidr i370 onco tcga ; do
cp pgs-calc-scores-merged/${d}/scores.info edison_prs_survival_analysis/${d}.scores.info
cp pgs-calc-scores-merged/${d}/scores.z-scores.txt edison_prs_survival_analysis/${d}.scores.z-scores.txt
gzip edison_prs_survival_analysis/${d}.scores.z-scores.txt
done

"""

