

See
```
/francislab/data1/working/20200909-TARGET-ALL-P2-RNA_bam/20200910-bamtofastq/
```



Need to install biobambam's bamtofastq

I think that I chose this app because the bam file doesn't need to be presorted.

```
git clone https://gitlab.com/german.tischler/libmaus2.git
git clone https://gitlab.com/german.tischler/biobambam2.git
cd libmaus2/
libtoolize 
aclocal
autoreconf -i -f
./configure --prefix=$HOME/.local
#configure: error: Required class std::unique_ptr<> not found
module load scl-devtoolset/7
./configure --prefix=$HOME/.local
#configure: error: Required std::filesystem functions not found
module load scl-devtoolset/8
./configure --prefix=$HOME/.local
make	#	this takes hours
make install



cd ../biobambam2
autoreconf -i -f
./configure --with-libmaus2=$HOME/.local --prefix=$HOME/.local
make	#	this takes a while as well
make install
```





```
./bamtofastq.bash
```



