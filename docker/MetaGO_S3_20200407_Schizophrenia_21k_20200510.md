
Each line is the complete path of raw data, such as the first line is '/home/user/MetaGO/testData/H1.fasta', and the second line is '/home/user/MetaGO/testData/H2.fasta' ... Furthermore, and the samples belong to same group must arrange togther(e.g. line1 to linek of the list belongs to group 1 (health) and linek+1 to lineN belongs to group 2 (patient) ).
-N	--n1	The number of samples belong to group 1.
-M	--n2	The number of samples belong to group 2.


/francislab/data1/working/20200407_Schizophrenia/20200407-21mer_matrix/trimmed/length/SD60.hg38.bowtie2-e2e.unmapped.fasta.gz

tail -n +2 /francislab/data1/raw/20200407_Schizophrenia/metadata.csv | awk -F, '{print "ln -s /francislab/data1/working/20200407_Schizophrenia/20200407-21mer_matrix/trimmed/length/"$1".hg38.bowtie2-e2e.unmapped.fasta.gz ./"$2"-"$1".unmapped.fasta.gz"}' | bash
ll Control-* | wc -l
29
ll Case-* | wc -l
30

aws s3 sync ~/MetaGO_S3_20200407_Schizophrenia/ s3://herv-unr/MetaGO_S3_20200407_Schizophrenia/



create_ec2_instance.bash --profile gwendt --image-id ami-0323c3dd2da7fb37d --instance-type i3.2xlarge --key-name ~/.aws/JakeHervUNR.pem --NOT-DRY-RUN
ssh ...
sudo yum update
sudo yum install docker htop

lsblk
sudo mkfs -t xfs /dev/nvme0n1
mkdir ~/ssd0
sudo mount /dev/nvme0n1 ~/ssd0/
sudo chown ec2-user ~/ssd0/

mkdir ~/ssd0/MetaGO_Result

aws s3 sync s3://herv-unr/MetaGO_S3_20200407_Schizophrenia/ ~/ssd0/MetaGO_S3_20200407_Schizophrenia/ 

Rename these files 

for f in ~/ssd0/MetaGO_S3_20200407_Schizophrenia/*unmapped.fasta.gz ; do n=${f/.unmapped/-unmapped}; mv $f $n ; done


lsblk
sudo mkfs -t xfs /dev/nvme1n1
mkdir ~/ssd1
sudo mount /dev/nvme1n1 ~/ssd1/
sudo chown ec2-user ~/ssd1/

sudo bash -c 'echo { \"data-root\":\"/home/ec2-user/ssd1/\" } >> /etc/docker/daemon.json'
sudo service docker start
sudo usermod -a -G docker ec2-user
exit
ssh ...


Using ssd0 as data in, ssd1 as data out and ssd2 as docker storage, or something like that.


mkdir ~/tmp/
cd ~/tmp/
wget https://raw.githubusercontent.com/ucsffrancislab/genomics/master/docker/MetaGO_demo.Dockerfile
docker build -t metago --file MetaGO_demo.Dockerfile ./


NO --rm 
Try -d and not -it

docker run -v /home/ec2-user/:/mnt --memory 200GB -itd metago

does --memory actually do anything???
Create filelist on docker instance so path is correct


ls -1 /mnt/ssd0/MetaGO_S3_20200407_Schizophrenia/Control* > /root/fileList.txt
ls -1 /mnt/ssd0/MetaGO_S3_20200407_Schizophrenia/Case*   >> /root/fileList.txt

nohup bash /root/github/MetaGO/MetaGO_SourceCode/MetaGO.sh --inputData RAW --fileList /root/fileList.txt --n1 29 --n2 30 --kMer 21 --min 1 -P 16 --ASS 0.65 --WilcoxonTest 0.1 --LogicalRegress 0.5 --filterFuction ASS --outputPath /mnt/ssd0/MetaGO_Result --Union --sparse > /mnt/ssd0/MetaGO_Result/MetaGO.output.txt 2>&1 &


dsk only using 8/32 processors. Why?


Started about noon.


last parts pegged all 8 processors and are using a lot of memory, currently 38.5/60 and rising
actually holding around 38.5

Much non-parallel processing happening. Wasted CPUs.
Seems to max out at 8-12 CPUs. 32 is a huge waste.

i3.2xlarge - 8/60GB - 14 hours
i3.8xlarge - 32/240GB - I think took about 12 hours

Just quit again. No idea why
Rerunning on bigger machine next time. i3.4xlarge?



aws s3 sync --delete ~/ssd0/MetaGO_Result/ s3://herv-unr/MetaGO_S3_20200407_Schizophrenia-MetaGO_result-i3.8xlarge-20200509/


----


ll /mnt/ssd0/MetaGO_Result/ASS*/part*

/home/ec2-user/ssd0/MetaGO_Result/ASS_filtered_down_*/part-?????
/home/ec2-user/ssd0/MetaGO_Result/WR_filtered_down_*/part-?????

Still ABSOLUTELY NOTHING?

Possible naming issue. The MetaGO convention splits on / and . and I have extra .'s
Actually not sure if that makes any difference


Just stopped in the middle of a sample? No idea why? Need to try this again with corrected names


Pegging 8CPUs, spiking to 3 or 4gb memory, storage will likely use 20GB
Think could've used a c5d.2xlarge ( 0.384 ), c5d.4xlarge ( 0.768 ) or m5[ad,d,dn].2xlarge ( 0.412, 0.452, 0.544 ) instead of i3.2xlarge ( 0.624 )





Could up parameters for memory and disk space

dsk
dsk: [d]isk [s]treaming of [k]-mers (constant-memory k-mer counting)
usage:
 dsk input_file kmer_size [-t min_abundance] [-m max_memory] [-d max_disk_space] [-o out_prefix] [-histo] [-c]
details:
 [-t min_abundance] filters out k-mers seen ( < min_abundance ) times, default: 1 (all kmers are returned)
 [-m max_memory] is in MB, default: min(total system memory / 2, 5 GB) 
 [-d max_disk_space] is in MB, default: min(available disk space / 2, reads file size)
 [-o out_prefix] saves results in [out_prefix].solid_kmers. default out_prefix = basename(input_file)
 [-histo] outputs histogram of kmers abundance
 Input file can be fasta, fastq, gzipped or not, or a file containing a list of file names.
 [-c] write a Minia-compatible output file, i.e. discard k-mer counts [-b] using existing binary converted reads
Running dsk version 1.6066

