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
PRS Survival Analysis #3

Included in the provided directory are data from 4 different datasets (cidr,i370,onco,tcga).
Each dataset was genotyped separately on a different SNP array.
Each dataset was then imputed separately on the UMich imputation servers.
Each dataset was then lifted over to hg38, filtered with R2>0.8 and normalized.
These vcf files were then scored against the majority of the 5000 model PGS catalog plus 7 additional custom models using pgs-calc.
pgs-calc generated a DATASET.scores.info json file that contains a variety of data from the scoring of each model.
Each dataset then had its scores scaled generating the DATASET.scores.z-scores.txt.gz file.
In addition each dataset has a set of covariates in DATASET-covariates.tsv.

The following is what I've asked you to do previously, however it will take too long so instead, take a small subset, a few percent, or whatever sounds doable, of the models and create the necessary code and wrapper scripts that I could run on our local slurm HPC cluster, either in an array job or a single large job that will take full advantage of our 64 CPU server, that will ...

---

For each dataset, run a survival analysis Cox models evaluating if each model is associated with glioma survival adjusting for
'source', 'age', 'sex', 'grade', 'rad', 'chemo', 'PC1', 'PC2', 'PC3', 'PC4', 'PC5', 'PC6', 'PC7', and 'PC8'
for each of the following subtypes:
* all cases (case=1)
* all IDH wildtype (case=1, idh=0) cases
* all IDH mutant (case=1, idh=1) cases
* all HGG IDH wildtype (case=1, grade=HGG, idh=0) cases
* all HGG IDH mutant (case=1, grade=HGG, idh=1) cases
* all LGG IDH wildtype (case=1, grade=LGG, idh=0) cases
* all LGG IDH mutant (case=1, grade=LGG, idh=1) cases
* all LGG IDH mutant 1p19q intact (case=1, grade=LGG, idh=1, pq=0) cases
* all LGG IDH mutant 1p19q codel (case=1, grade=LGG, idh=1, pq=1) cases

Produce tables of the top associations by model and subset.
After completion, combine all 4 datasets and meta analyze the results across individual studies using METAL or something like METAL.
Produce volcano plots for each subtype, forest plots and multi-dataset Kaplan-Meier Comparison plots for top 20 meta-analysis hits.

---

Be sure to include all commands that I need to run beforehand, like installing python packages.
Be sure that this code works and includes some testing.
Include the commands needed to test that that code works so that I can run it before trying to run the full analysis.
Include instructions and parameters that I can use to select the appropriate files.

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

