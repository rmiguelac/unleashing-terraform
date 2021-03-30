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

#### Attributes and output values

Very important

If I want to take the public ip, s3 bucket, a domain name, any information, I can demand this information from Terraform

outputs can work as inputs for other resources (ip whitelisted in security group, for example). This looks like the terraform interpolation.

```hcl
resource "aws_eip" "lb" {
    vpc     = true
}

output "blabla" {
    value   = aws_eip.lb.public_ip 
}
```

Those fields can ben found in the documentation of the provider under the **Attributes Reference**

If i deleted public_ip from the value above, I will see _all_ atributes
Also, the output is in the state file

!!!!!!!!!! TRY THIS

OBS: Comments in tf are achieved with ```/* */```

OBS: If you require to concat a variable to a string or int, the terraform interpolation might fail. To do so, use "${resource.name.field}/32"

#### Variables

we can defines variables in the default style

```hcl
variable "bla" {
    default = "ble"
}
```

If we define a variable empty, terraform will ask for it during the execution

we can also define variables in the command line, using the this will have a higher precedence over the top one

```hcl
terraform plan -var="instancetype=t2.small"
```

Also, variables can come from a file, which should be called ```terraform.tfvars```. It will be taken automatically, no need to reference it. If, by any request, we need to have a file with a different name, we must explicit reference it with ```terraform plan -var-file="your_var_file.tfvars" ```

Best practise is having a variable with default value. Also, we should have tfvars file so we can overwrite the values (like helm values)

Lastly, we can use environment variables to define variables within terraform. For that, those environment variables must start with the prefix ```TF_VAR_``` followed by the variable name we want, meaning, if we want to define the ``` nsg_name ``` as environment variable, the linux/mac/windows env var should be defined as ``` TF_VAR_nsg_name ```. 

OBS: precedence for variables is first:
1. load from environment variables
2. load from .tfvars (lexical order)
3. load from .tfvars.json (lexical order)
4. load form -var or -var-file

where 1 is less precedence and 4 is higher precedence

> file > env

OBS: We can define custom variable validation https://www.terraform.io/docs/language/values/variables.html