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
    	name="Directory containing the cidr/i370/onco/tcga covariates and lists",
    	file_path="./edison_normalization_check",  # ADD DATASET FOLDER PATH HERE
    	description="This is a directory that will be be analysed by Edison Analysis",
    	as_collection=True,
	)
	print("Finished Uploading", flush=True)
	return response

directory_upload_response = asyncio.run(upload())



query = """
Covariate Normalization Check #1

I have 4 separate datasets: cidr, onco, i370 and tcga.

They have different covariate metadata files, {DATASET}_covariates.tsv, with different columns and it is overly complicated.

In addition each dataset has lists of subset cases which in general correspond to one or more columns in the covariate file:
* {DATASET}_ALL_meta_cases.txt
* {DATASET}_HGG_IDHmut_meta_cases.txt
* {DATASET}_HGG_IDHwt_meta_cases.txt
* {DATASET}_IDHmut_meta_cases.txt
* {DATASET}_IDHwt_meta_cases.txt
* {DATASET}_LrGG_IDHmut_1p19qcodel_meta_cases.txt
* {DATASET}_LrGG_IDHmut_1p19qintact_meta_cases.txt
* {DATASET}_LrGG_IDHmut_meta_cases.txt
* {DATASET}_LrGG_IDHwt_meta_cases.txt

I am trying to unify / normalize / synchronise the covariate file format to make it easier to use in the future and remove the need for the lists altogether so I wrote the attached script normalize_covariates.bash and converted the covariate files like so ... 

```
./normalize_covariates.bash cidr cidr-covariates.tsv > cidr-covariates.csv
./normalize_covariates.bash i370 i370-covariates.tsv > i370-covariates.csv
./normalize_covariates.bash onco onco-covariates.tsv > onco-covariates.csv
./normalize_covariates.bash tcga tcga-covariates.tsv > tcga-covariates.csv
```

I am concerned that I may have made mistakes or inadvertantly used the wrong column or assumed its value meant one thing or another.  Nevertheless, for each dataset, take the input covariate file and it's lists and check my work when creating the new covariate file {DATASET}-covariates.csv.

Ensure that:
* case matches case/control status
* LrGG/HGG consistently matches the tumor grade
* IDHwt/IDHmut consistently matches the IDH status
* intact/codel consistently matches the 1p19q status
and report which columns that should be used for each dataset.

Ignore the fact that the PCs may be different as they were computed afterwards.

Check that my script is selecting the correct column or columns when creating the new covariate file and report if any are incorrect and should be changed.

Check that the results for all 4 datasets are consistent so that they can be compared and processed together..

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


