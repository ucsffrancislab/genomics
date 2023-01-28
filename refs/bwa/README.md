



bwa index -p hg38_chr6 /francislab/data1/refs/Homo_sapiens/UCSC/hg38/Sequence/Chromosomes/chr6.fa


module load bwa
bwa index -p hg38.chrXYM_alts /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa


bwa mem -o OUTPUT.sam /francislab/data1/refs/bwa/hg38.chrXYM_alts INPUTS


Usage: bwa mem [options] <idxbase> <in1.fq> [in2.fq]

Algorithm options:

       -t INT        number of threads [1]
       -k INT        minimum seed length [19]
       -w INT        band width for banded alignment [100]
       -d INT        off-diagonal X-dropoff [100]
       -r FLOAT      look for internal seeds inside a seed longer than {-k} * FLOAT [1.5]
       -y INT        seed occurrence for the 3rd round seeding [20]
       -c INT        skip seeds with more than INT occurrences [500]
       -D FLOAT      drop chains shorter than FLOAT fraction of the longest overlapping chain [0.50]
       -W INT        discard a chain if seeded bases shorter than INT [0]
       -m INT        perform at most INT rounds of mate rescues for each read [50]
       -S            skip mate rescue
       -P            skip pairing; mate rescue performed unless -S also in use

Scoring options:

       -A INT        score for a sequence match, which scales options -TdBOELU unless overridden [1]
       -B INT        penalty for a mismatch [4]
       -O INT[,INT]  gap open penalties for deletions and insertions [6,6]
       -E INT[,INT]  gap extension penalty; a gap of size k cost '{-O} + {-E}*k' [1,1]
       -L INT[,INT]  penalty for 5'- and 3'-end clipping [5,5]
       -U INT        penalty for an unpaired read pair [17]

       -x STR        read type. Setting -x changes multiple parameters unless overridden [null]
                     pacbio: -k17 -W40 -r10 -A1 -B1 -O1 -E1 -L0  (PacBio reads to ref)
                     ont2d: -k14 -W20 -r10 -A1 -B1 -O1 -E1 -L0  (Oxford Nanopore 2D-reads to ref)
                     intractg: -B9 -O16 -L5  (intra-species contigs to ref)

Input/output options:

       -p            smart pairing (ignoring in2.fq)
       -R STR        read group header line such as '@RG\tID:foo\tSM:bar' [null]
       -H STR/FILE   insert STR to header if it starts with @; or insert lines in FILE [null]
       -o FILE       sam file to output results to [stdout]
       -j            treat ALT contigs as part of the primary assembly (i.e. ignore <idxbase>.alt file)
       -5            for split alignment, take the alignment with the smallest query (not genomic) coordinate as primary
       -q            don't modify mapQ of supplementary alignments
       -K INT        process INT input bases in each batch regardless of nThreads (for reproducibility) []

       -v INT        verbosity level: 1=error, 2=warning, 3=message, 4+=debugging [3]
       -T INT        minimum score to output [30]
       -h INT[,INT]  if there are <INT hits with score >80.00% of the max score, output all in XA [5,200]
                     A second value may be given for alternate sequences.
       -z FLOAT      The fraction of the max score to use with -h [0.800000].
                     specify the mean, standard deviation (10% of the mean if absent), max
       -a            output all alignments for SE or unpaired PE
       -C            append FASTA/FASTQ comment to SAM output
       -V            output the reference FASTA header in the XR tag
       -Y            use soft clipping for supplementary alignments
       -M            mark shorter split hits as secondary

       -I FLOAT[,FLOAT[,INT[,INT]]]
                     specify the mean, standard deviation (10% of the mean if absent), max
                     (4 sigma from the mean if absent) and min of the insert size distribution.
                     FR orientation only. [inferred]
       -u            output XB instead of XA; XB is XA with the alignment score and mapping quality added.

Note: Please read the man page for detailed description of the command line and options.






bwa mem -o OUTPUT.sam /francislab/data1/refs/bwa/hg38.chrXYM_alts 
 -t INT        number of threads [1]

 -R STR        read group header line such as '@RG\tID:foo\tSM:bar' [null]

INPUTS





tar cf hg38.chrXYM_alts.tar hg38.chrXYM_alts.[abps]*



python3


#The configuration file, $HOME/.sevenbridges/credentials, has a simple .ini file format, with the environment (the Seven Bridges Platform, or the CGC, or Cavatica) indicated in square brackets, as shown:
#	
#	[default]
#	api_endpoint = https://api.sbgenomics.com/v2
#	auth_token = <TOKEN_HERE>
#	
#	[cgc]
#	api_endpoint = https://cgc-api.sbgenomics.com/v2
#	auth_token = <TOKEN_HERE>
#	
#	[cavatica]
#	api_endpoint = https://cavatica-api.sbgenomics.com/v2
#	auth_token = <TOKEN_HERE>
#	c = sbg.Config(profile='cgc')
#api = sbg.Api(config=c)

import sevenbridges as sbg
c = sbg.Config(profile='cgc')
api = sbg.Api(config=c)

api.users.me()

for project in api.projects.query().all():
	print (project.id,project.name)


project = api.projects.get(id='wendt2017/sgdp')

for file in api.files.query(project=project).all():
	print(file.id,file.name)


refs=api.files.query(project=project,names=['references'],limit=1)[0]
bwa=api.files.query(parent=refs.id,names=['bwa'],limit=1)[0]

upload=api.files.upload('hg38.chrXYM_alts.tar', parent=bwa, wait=False)

upload.status
#'PREPARING'

upload.start() # Starts the upload.

upload.status
#'RUNNING'

upload.status

upload.progress
upload.progress
upload.progress
upload.progress
upload.progress


upload.progress
#	0.01000673635349509		#  MAX?

upload.status
#'COMPLETED'

#	Surprisingly fast

