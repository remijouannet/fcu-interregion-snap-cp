# fcu-interregion-snap-cp

************
Introduction
************
A python script to copy snapshot from one region to another

*******
Install
*******

copysnapshot require boto (<= 2.33 if you use it on region eu-west-1 or us-east-1) and paramiko :
```shell
pip install -r requirements.txt
```

*****
Usage
*****
```shell
copysnapshot --ak-dst <AK region dest> --sk-dst <SK region dest> --region-dst <region dest name> --ak-src <AK region src> --sk-src <SK region src> --region-src <region src name> --my-ip <public ip of computer running script> --snap-id <source snapshot id> [--disk <number of disks used>] [--no-compress ]
```

This script create a instance in source and destination regions. On source region it create N volumes from snapshot source,
 and on destination region one empty volumes. Then it use dd and ssh to transfert data between the two instance.
Data transfert is chuncked in block of 1GB, and several block are transfered in parallel (depending of number of disks).
Data may be compressed before transfer.
Compression can have a positive or negative impact on speed transfert depending on data inside snapshot
Compression and number of disks used define the size of the instance source and destination. You must check that you have the right quota

After data transfert, allocated objects are destroyed (instances,volumes,keys pairs, security groups), in case of error, 
the script try to destroy allocated objets, but you must check that all objects are destroyed. 
All allocated objects are taged/named in the form : temp_<reg>_<object>_<id_snap_src> where reg is "src" or "dst" ; objet is the object type
(vm,vol,key,sg) and id_snap_src the id of source snapshot

Actually the script contain 2 regions definitions, you can edit the script to add or modify region. You must be edit the region definition if images id for instance change. each region need 3 parameters : 
omi -> image id to create instance (Centos 7 recommended) 
iops -> max numbers of iops per volume
iopsfact -> min numbers of iops per GB
```python
regions = {
    'eu-west-1': {'omi': 'ami-a4e5e1ed', 'iops': 2000, 'iopsfact': 10},
    'eu-west-2': {'omi': 'ami-0175d923', 'iops': 4000, 'iopsfact': 30}
}
```

