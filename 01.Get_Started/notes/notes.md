## Notes

A little bit more of terraform state

#### Desired and Current state

desired state = in the .tf
current state = actual state in the provider

terraform tries to ensure that desired state is followed \
terraform will try to change back to what is in the .tf and not in the current state

```hcl
terraform refresh 
```

This command gets the curret state of the resources and **will update the state** file

next ```terraform plan``` will show the changes that need to take place to go back to 
the desired state

OBS: ```terraform plan``` calls ```terraform refresh``` internally
OBS2: If we dont specify something in the .tf file, for example, the security group of a VM and it ends up creating/using a default one, if we change it in the AWS console and run ```terraform plan```, it won't show anything to update. The take here is, specify as much info as you can

#### Provider versioning

+----------------+----------------------------------+
| Version        |      Versions taken              |
+----------------+----------------------------------+
| >=1.0          | Greater than or equal to         |
| <=1.0          | Less than or equal to            |
| ~>2.0          | Any version in 2.X range         |
| >=2.10,<=2.30  | Any version between 2.10 and 2.30|
+----------------+----------------------------------+

The file .terraform.lock.hcl locks the version that the provider will use
If we change the version on the provider havint the lock file, it wont work.
Going from ~>3.0 to ~>2.0 will fail. Need to delete the file or

```terraform init -upgrade```

