#!/usr/bin/env python3

import os
import time
import asyncio
import shutil
from pathlib import Path
from edison_client import EdisonClient
from edison_client import JobNames
from edison_client import TaskRequest
from edison_client.models import RuntimeConfig
#from ldp.agent import AgentConfig

with open("/c4/home/gwendt/EDISON_API_TOKEN", 'r') as file:
	api_key = file.read()

api_key = api_key.rstrip()	# Cannot include a carriage return
print(api_key, flush=True)

client = EdisonClient(api_key=api_key)
print("Set client", flush=True)


#	https://edisonscientific.gitbook.io/edison-cookbook/edison-client/docs/edison_analysis_tutorial


trajectory_id="916364b4-d11b-40fe-9632-77fe3bd78075"

status = "in progress"
while status in {"in progress", "queued"}:
	status = client.get_task(trajectory_id).status
	time.sleep(15)

if status == "failed":
	raise RuntimeError("Task failed")

job_result = client.get_task(trajectory_id, verbose=True)
answer = job_result.environment_frame["state"]["state"]["answer"]
print(f"The agent's answer to your research question is: \n{answer}", flush=True)

output_data = job_result.environment_frame["state"]["info"]["output_data"]
print(output_data, flush=True)


async def download():
	for output_file in output_data:
		response = await client.afetch_data_from_storage(
			data_storage_id=output_file["entry_id"]
		)

		# Note there are two potential outcomes here. One where the client downloads
		# the file to your local filesystem if it's above ~10MB. The second is where
		# it will return a RawFetchResponse object which contains the raw content.
		#print(download_response, flush=True)

		#filename = os.path.basename(response['filename'])
		#[{'entry_id': '5a6fcd6794764c7fbb880911a7101595', 'filename': 'survival_analysis.py', 'file_size': 8721}
		print(output_file['filename'], flush=True)

		# Define your custom path
		custom_path = os.getenv("PWD")
		full_path = os.path.join(custom_path, output_file['filename'])
		print(full_path, flush=True)

		## Write the data to the specified location
		#with open(full_path, "wb") as f:
		#	f.write(response)


		print(f"Saving to: {full_path}", flush=True)

		if isinstance(response, Path):
			# Large file: already downloaded to a temp path, just move it
			shutil.move(str(response), full_path)
		else:
			# Small file: response contains raw bytes (or RawFetchResponse)
			content = response.content if hasattr(response, 'content') else bytes(response)
			#with open(full_path, "wb") as f:
			#	f.write(content)
			with open(full_path, "w") as f:
				f.write(content)

	print("Finished Downloading", flush=True)

asyncio.run(download())


