

##	One time setup ...

###	Install VirtualBox ...

https://www.virtualbox.org/wiki/Downloads


###	Install homebrew

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```


###	Install vagrant

```
brew install --cask virtualbox && brew install --cask vagrant && brew install --cask vagrant-manager && brew install --cask vagrant-vmware-utility
```

###	Prep vagrant 

```
vagrant init sylabs/singularity-ce-3.9-ubuntu-bionic64 
```




##	Then when developing


###	Prep

```
vagrant up

vagrant ssh

cd /vagrant
```



###	Build

```
sudo singularity build SQuIRE.img SQuIRE.def 2>&1 | tee SQuIRE.out
```



```
sudo singularity build MEGAnE.v1.0.0.beta-20230525.sif docker://shoheikojima/megane:v1.0.0.beta
```



###	Cleanup

```
exit
vagrant destroy
```





##	Other


###	Disk Size

Looks like the default disk size for vagrant is about 20G.
If more is needed, as is the case when building MEGAnE, ...

```
df -h /
Filesystem                    Size  Used Avail Use% Mounted on
/dev/mapper/vagrant--vg-root   19G  8.7G  9.1G  49% /

vagrant plugin install vagrant-disksize
```


Modify VagrantFile

```
  config.disksize.size = '50GB'
```


Exit
```
exit
vagrant destroy
```

Restart
```
vagrant up
```


You should see something like ... (in green for me)
```
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Resized disk: old 20480 MB, req 51200 MB, new 51200 MB
==> default: You may need to resize the filesystem from within the guest.
==> default: Booting VM...
```

Connect
```
vagrant ssh
```


Confirm. The disk space will likely be there, but not fully mounted.
```
sudo fdisk -l /dev/sda
```


So, how to actually mount?


Seems to require interactivity
```
sudo cfdisk /dev/sda
```


```
sudo pvresize /dev/sda1
sudo pvresize /dev/mapper/vagrant--vg-root
sudo lvresize /dev/mapper/vagrant--vg-root -L 49G
sudo resize2fs -p -F /dev/mapper/vagrant--vg-root
```


```
cd /vagrant
```

Check

```
df -h /
```




