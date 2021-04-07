## Provisioners

#### remote-exec   x   local-exec

Provisioner will actually configure/install software
For example, this case we execute something remotelly with **remote-exec** \
We also have **local-exec**, which can be used for running ansible playbooks. \
More than that, there are **chef** and other provisioners as well.

```hcl
resource "aws_instance" "myec2" {
    ami = ...
    ...

    privisioner "remote-exec" {
        inline = [
            "sudo amazon-linux-extras install -y nginx1.12"
            "sudo systemctl start nginx"
        ]

        connection {
            type    =   "ssh"
            host    =   "self.public_ip
            user    =   "ec2-user"
            private_key =   "${file("/.terraform.pem")}"
            # Could be username/password as well instead of private_key
        }
    }
}
```

**TASK:** Create a VM and run an ansible playbook using local-exec that installs nginx and puts a custom index file


#### creatime-time    x   destroy-time

There are two scopes that define _when_ a privisioner will run. Those are **creation-time** and **destroy-time** meaning that a provisioner can run while a resource is being created (not during update or any other lifecycle) and, if the creation fails the resource is marked as tainted, or destroyed

While in destroy-time, whatever is defined runs first, then the resource is destroyed.

#### Provisioner types (creation-time x destroy-time)

Creation-time - only run when resource is created and, if it fails, the resource is marked as tainted

Destroy-time - runs before the resource is actually destroyed

```hcl
resource "" {


    provisioner "local-exec" {
        when = destroy
        command = ...
    }    
}
```

#### Failure behaviour

Provisioner that fails causes the terraform apply to fail as well.

that can change with the **on_failure**, giving the value of _continue_, that can ignore the error and continue with creation or destruction. The other possible value is _fail_, which is the default value.

```hcl
resource "" {

    provisioner "local-exec" {
        command = ...
        on_failure = continue
    }    
}
```

## Modules and Workspaces

#### DRY Principle and modules

Using modules
To use modules, we define the modules block

```hcl
module "X" { 
    source = "../../module/vm"
}
```

to override what is defined in the module, first the module must make use of variables. After that, when calling the module, we can overwrite it with:

```hcl
module "rg_module" {
  source = "../../modules/vm"
  location = "eastus"
}
```

where we added the location to override the _brasilzouth_ variable from the module itself. If something must be static, do not put it as var.

#### modules in the registry

There are also modules in registry, not only providers.
Look for verified modules, they are maintained from thirdparty contributors, some the providers themselves - it has a hexagonal blue badge.

For example: https://registry.terraform.io/modules/Azure/aks/azurerm/latest

To use those kind of modules, we define the module a little bit differently:

```hcl
module "aks" {
    source = "Azure/aks/azurerm" 
    version = "4.8.0"

    var 1 = ...
    var 2 = ...
    ...
    var n = ...
    ...
}
```

#### Workspace

Terraform allows us to have multiple workspaces. 
Each workspace can have different environment variables.
To show workspaces ```terraform workspace list``` and ```terraform workspace show``` to see which one is active.