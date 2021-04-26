## Review

#### Providers

What are providers and what capabilities they offer.

* understand api interactions and expose resources
* most corresponde to cloud or on-prem infrastructure platform
* to upgrade to latest acceptable version of each provider, run ```terraform init -upgrade```

Flow is:

.tf files -> Terraform -> provider plugin -> api calls to actual provider
           . Terraform <- provider plugin <- response from api calls

**OBS:** Provider configuration block is not mandatory for all the terraform configuration. An example of this would be the ```locals``` block used with an ```output``` block, only.


#### Initialization

* ```terraform init``` initializes the working directory containing .tf configuration files
* during ```init```, the configuration is searched for module blocks, source is fetched
* Terraform must initialize the provider before it can be used
* Initialization downloads and installds the provider's plugin
* It does not create any sample files

#### Plan

Used to create an ```execution plan```

* Does not modify infrastructure
* Terraform performas a ```refresh```, unless explicitly disabled, then determines what actions are necessary to achieve the desired state specified in the configuration files.
* Convenient way to check whether the execution plan for a set of changes matches your expectations without making any changes to real resources or to the state

**Know the difference between desired state and current state**

To know what will be destroyed with the plan command, we can:

```bash
$ terraform plan -destroy
```

#### Apply

Used to apply changes required to reach the desired state of configuration

* Terraform apply will also write data to the ```terraform.tfstate``` file
* apply can ```change```, ```destroy``` and ```provision``` resources but cannot import any resource.

Once apply is completed, resources are immediately available

#### Refresh

The ```terraform refresh``` command is used to reconcile the state Terraform knows about (via state file) with the real-world infrastructure

* This does not modify the infra, but modify the state file
* ```plan```, ```apply``` and ```destroy``` run refresh implicitly
    * ```init``` and  ```import``` do not run it.

#### Destroy

The ```terraform destroy``` command is used to destrou the Terraform-managed infrastructure

* ```terraform destroy``` is not the only command through which infrastructure can be destroyed
    * if we remove something from the .tf file and then run terraform apply, it will destroy the resource that was previosuly there.

#### Format

The ```terraform fmt``` commandis used to rewrite the Terraform configuration files to a canonical format and style

#### Validate

The ```terraform validate``` validates the configuration files in a directory

Validates:
* whether a configuration is syntactically valid and thus primarily useful for general verification of reusable modules, including the correctness of attributes names and value types
* safe to run as it does not make anychanges
* requires an initialized directory (with plugins installed)

#### Provisioners

Terraform provisioners can be used to model specific actions on the local machine or on a remote machine.

**Provisioners should only be used as a last resort. For most common situations, there are better alternatives**

```hcl
resource "aws_instance" "web" {
    ...

    provisioner "local-exec" {
        command = "echo 'Blablalba'"
    }
}
```

**Provisioners are _inside_ the ```resource``` block, don't forget**

##### Provisioner - local-exec

the _local-exec_ provisioner invokes a local executable after a resource is created. This invokes a process on the machine running Terraform, not on the resource.

##### Provisioner - remote-exec

_remote-exec_ provisioners invokes a script on a remote resource after it is created.  
The remote-exec supports both ```ssh``` and ```winrm``` type of connections.

```hcl
resource "aws_instance" "web" {

    provisioner "remote-exec" {
        inline [
            "yum -y install nginx"
            "yum -y install nano"
        ]
    }
}
```

##### Provisioner - Failure behaviour

By default, provisioners that fail will also cause Terraform apply to fail.  
The ```on_failure``` setting can be used to change this. The allowed values are:

* continue  = ignore the error and continue with creation or destruction
* fail      = raise an error ands top applying - default.
              if this is a creation provisioner, taint the resource.

##### Provisioner - Types

* creation-time provisioner = only run during creation. If it fails in this type, resource is tainted
* destroy-time provisioner  = run before the resource is destroyed

#### Debugging

To debug, we can set the ```TF_LOG``` to one of the following

```TRACE```, ```DEBUG```, ```INFO```, ```WARN``` or ```ERROR```.

To persist the log output, the variable ```TF_LOG_PATH``` can be used.


#### Import

Capability of importing existing infrastructure.  
Allows taking resources created without terraform under terraform management.
Import only puts the resources under the state file, not in the configuration, which makes a necessity to wirte the configuration block prior to the ```terraform import``` command.

```terraform import aws_instance.myec2 instance-id-from-aws```

#### Local values

Assign a name to an expression, allowing it to be used multiple times within a module without reating ig.  

#### Workspaces

Terraform allow us to have multiple workspaces. Each WS can have a different set of environment variables associated.

* Workspaces allow multiple state files of a single configuration.
* managed by the ```terraform workspace``` commands
* state file directory can be ```terraform.tfstate.d```

create workspace    = ```terraform workspace new bla```
    creates and switch to it, no need to switch.
switch workspace    = ```terraform workspace select bla```

#### Modules

Need to be aware of modules, what is ```root``` module as well as ```child``` modules.

```hcl
module "servers" {
    source = "./app-cluster"

    servers = 5
}
```

this is an example of a calling module of a child module.

###### Modules - Accessing Output Values

Resources defined in a module are encapsulated, so the calling module cannot access their attributes directly. For that, child module can declare output values to selectively export certain values to be accessed by the calling module.

```hcl
output "instance_ip_addr" {
    value = aws_instance.server.private_ip
}
```

###### Modules - Versions

It is recommended to explicitly constraint the acceptable version numbers of each external module to avoid unexpected or unwanted changes.

Versions are only supported for modules installed from a module registry, such as Terraform Registry or Terraform Cloud's private module registry

* Versions are not required when pulling from terrefrom registry

#### Supressing values in CLI Output

An output can be marked as containing sensitive material using the optional sensitive argument:

```hcl
output "db_password" {
    value = ...
    sensitive = true
}
```

even though the output of the CLI will not show the value, as it is marked as **sensitive**, the state file will still have it, plain.


#### Terraform Registry

Registry is integrated directly into Terraform.  
The syntax for referencing a registry moduel is:  

```<NAMESPACE>/<NAME>/<PROVIDER>```

For example:

``` hashicorp/consul/aws```

```hcl
module "consul" {
    source = "hashicorp/consul/aws"
    version = "0.1.0"
}
```

For **private registries**, the reference should be on the form of:

```<HOSTNAME>/<NAMESPACE>/<NAME>/<PROVIDER>```

For example:

```hcl
module "vpc" {
    source = "app.terraform.io/example_corp/vpc/aws"
    version = "0.9.3"
}
```

**Version is required!!**

#### Functions

What are, be able to use like ```element``` and ```lookup```

* Slice function is not part of the string function.
    * others like join, split, chomp are part of it

```lookup(map, key, default)```

#### Lock and unlock

Depending on the backend selected, know what lock and unlock does and how to bypass it.

#### Current state x Desired State

Current = real state, obtained from refresh
Desired = state from the .tf files

#### Resource block

Each resource block describes one or more infrastructure objects, such as VNets, VMs or other stuff.  
Resource blocks have given ```types``` and ```local names```, like the following:

```hcl
resource "aws_instance" "web" {
    ami     = "ami-abdc1234"
    instance_type = "t2.micro"
}
```

where **aws_instance** is the ```type``` and **web** is the ```local name```


#### Sentinel

Sentinel is a embededed policy-as-code framework integrated with HashiCorp Enterprise products

terraform plan -> sentinel checks -> terraform apply

#### Sensitive data in state file

Sensitive data will be in plain sight in the state file, so treat the state file as sensitive.  
Terraform Cloud always encrypts the state at rest and protects it with TLS in transit.  
Terraform Cloud also knows the identity of the user requesting state and maintains a history of state changes.

The S3 backend supports encryption at rest when the encrypt option is enabled.

#### Dealing with credentials in Config

Do not hardcode credentials in Terraform configuration.  
Control credentials outside of terraform configuration.  
Storing credentials as part of environment variables is a much better approach than hardcoding it.

#### Remote backend for Terraform Cloud

The remote backend stores Terraform state and my be used to run operations in Terraform Cloud.  

When using full remote operations, operations like terraform plan or terraform apply can be executed in Terraform Cloud's run environment, with log outputs streaming to the local terminal.

#### Misc

* Terraform **does not** require _go_ as a prerequisite.
* Terraform works well in Windows, Linux and MAC.
* Windows Server is not mandatory.
* Do not overuse dynamic blocks as it makes the configuration hard to read and maintain.

#### Graph

Terraform's ```terraform graph``` command is used to generate a visual representation of either a configuration or execution plan. Be aware that the command output is a **DOT format** file, which still needs to be converted to an image.

#### Splat Expression

Splat expression allows us to get a list of all the attributes (Linux globbing)

```hcl
output "arns" {
    value = aws_iam_user.lb[*].arn
}
```

Where the _splat expression_, is the the make use of _[*]_

#### Terminology

```hcl
resource "aws_instance" "example" {
    ami = "ami-abcd1234"
}
```

* resource type     = "aws_instance"
* local name        = "example
* argument name     = "ami"
* argument value    = "ami-abcd1234"

#### Output

Terraform's ```terraform output``` command is used to extract the value of an output variable from the state file.

```bash
$ terraform output iam_names
[
    "iam1",
    "iam2",
    "iam3"
]
```

#### Unlock

If supported by the backend, Terraform will lock the state for all write operations.  
Not all the backends supports locking functionality.  
This was introduced in version 0.14.  

Terraform has a force-unlock command to manually unlock the state if unlocking failed.  

```bash
$ terraform force-unlock LOCK_ID [DIR]
```

#### IaC benefits

* Automation
* Versioning
* Reusability

#### IaC Tools

* Terraform
* CloudFormation
* Azure Resource Manager
* Google Cloud Deployment Manager

#### Terraform Enterprise and Terraform Cloud

On top of _Terraform Cloud_, _Terraform Enterprise_ provides several added advantages/features.

* SSO
* Auditing
* Private Data Center Networking
* Clustering

_Team & Governance_ features are not available for Terraform Cloud Free

#### Variables with undefined values

If variables with undefined values are created, it will not directly result in an error, Terraform with ask you to supply those, for example:

```hcl
variable custom_var { }
```

```bash
$ terraform plan
var.custom_var
  Enter a value:

```

#### Environment Variables

Environment variables can be used to set variables. They must be in the format ```TF_VAR_name```.

```bash
$ export TF_VAR_regions=us-west-1
$ export TF_VAR_ami=ami-0419sb18
$ export TF_VAR_alist='[1,2,3]'
```

#### Structural Data Type

structural data type allows us to group multiple values, of several distinct types, together as a single value.

* ```Lists``` contain multiple objects of same time, ```object``` on the other hand can contain multiple values of different types

```
object(
    {
        name = string,
        age = number
    }
)
```

```
{
    name = "John"
    age  = 52
}
```

This can be achieve with tuples as well.

#### Backend configuration

Backends are configured directly in Terraform files in the _terraform section_.  
After configuring a backend, it has to be initialized.

```hcl
terraform {
    backend "s3" {
        bucket  = ...
        key     = ...
        region  = ...
    }
}
```

##### First time configuration

When configurting backend for the first time (moving from no defined backend to explicitly configuring one), Terraform will give you an option to migrate your state to the new backend.

This lets you adopt backends without losing any existing state.

##### Partial time configuration

You do not need to specify every required argument in the backend configration.  
Ommitting certain arguments may be desirable to avoid storing secrets, such as access keys, within the main configuration. 

With a partial configuration, the remaining configuration arguments must be provided as parf of the initalization process

```hcl
terraform {
    backend "consule" { }
}
```

```bash
$ terraform init \
  -backend-config="address=demo.consul.io" \
  -backend-config="path=example_app/terraform_state" \
  -backend-config="scheme=https"
```

#### Taint

Taint command manually marks a terraform-managed resource as tained, forcing it to be destroyed and recreated on the next apply.

Once a resource is marked as tainted, thenext plan will show that the resource will be destroyed and recreated and the next apply will implement this change.

We can also taint resources within a module.

```bash
$ terraform taint "module.couchbase.aws_instance.cb_node[9]"
```

for submodules

_module.foo.module.bar.aws_instance.qux_

#### Input variables

Input variables can be assigned via multiple approches:

```hcl
variable "image_id" {
    type = string
}
```

CLI as well as tfvars file.

```bash
$ terraform apply -var-file="testing.tfvars"
```

variable files that will be loaded automatically

* terraform.tfvars
* terraform.tfvars.json
* any files with names ending in .auto.tfvars.json

#### Variable precedence

* environment variables
* terraform.tfvars file, if present
* terraform.tfvars.json file, if present
* Any *.auto.tfvars or *.auto.tfvars.json files, processedin lexical order of their filenames
* Any -var and -var-file options on the command line, in the provided order.

**OBS:** If the same variable is assigned multiple values, Terraform uses the last value it finds.

#### Terraform local backend

Local backend stores state on the local filesystem, locks that state using system APIs and performs operations locally.

By default, Terraform uses the "local" backend, which is the normal behavior of Terraform you're used to 

```hcl
terraform {
    backend "local" {
        path    = "relative/path/to/terraform.tfstate"
    }
}
```

#### Required providers

Each terraform module must declare which providers it requires, so that Terraform can install and use them.

Provider requirements are declared in a ```required_providers``` block

```hcl
terraform {
    required_providers {
        mycloud = {
            source = ...
            version = ...
        }
    }
}
```

#### Terraform required version

The ```required_version``` setting accepts a version constraint string, which specifies which versions of Terraform can be used with  your configuration

If the running version of Terraform doesn't match the constraints specified, Terraform will product an error and exit without taking any further actions

#### Fetching values form a map

```hcl
variable "ami_ids" {
    type = "map"
    default = {
        "brazil" = "lala"
    }
}
```

var.ami_ids["brazil"]

#### Dependency

Implicit X Explicit - know it

#### State command

Terraform's ```terraform state``` command can be used in many cases other than modifying the state:

```terraform state list```  = list resources in terraform state
```terraform state mv```    = move items within terraform state. Can be used to resource renaming
```terraform state pull```  = manually download and output the state from state file.
```terraform state rm```    = remove items from terraform state file
```terraform state show```  = show the attributes of a single resource in the Terraform state

#### Data source code

* allows data to be fetched or computed for use elsewhere in Terraform configuration
* reads from specific data source and exports results

```hcl
data "aws_ami" "app_ami" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name    = ...
        values  = ...
    }
}
```

```hcl
resource "aws_instance" "instance-1" {
    ami           = data.aws_ami.app_ami.id
    instance_type = "t2.micro"
}
```

#### Dealing with Larger Infrastructure

Cloud providers implement rate limited, which makes Terraform only be able to request a certain amount of resources at a time.

It is important to break larger configurations intomultiple smaller configurations that can be independently applied.

Alternative, you can make use of -refresh=false and target flag for a workaround (not recommended)