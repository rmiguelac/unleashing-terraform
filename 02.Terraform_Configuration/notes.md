#### Count parameter

Use case: When we need to create multiple resources that only differ by a number (2 vms, for example)
How to use: 

This:

```hcl
resource "provider_vm" "instance-1" {
    name = "instance-1"
    ...
}

resource "provider_vm" "instance-2" {
    name = "instance-2"
    ...
}
```

should become:

```hcl
resource "provider_vm" "instance-1" {
    name = "instance-1"
    ...
    count = 2
}
```
The problem with this approach is that every VM will have _instance-1_ name. For that, the count index exists

#### Count index

To use count index to name the resource according to the count index, we do:

```hcl
resource "provider_vm" "instance-1" {
    name = "instance".${count.index}
    count = 5
}
```

We can customize the variable iteration for the count. For that, we define a variable with a list

```hcl
variable "bs" {
    type = list
    default = ["kafka", "elastic", "spark"]
}
```

and then define the resource to use it

```hcl
resource "provider_vm" "instance1" {
    name = var.bs[count.index]
    ...
    count = 3
}
```

#### Conditional Expressions

condition ? true_val : false_val

```hcl
variable "is_dev" {
    type = bool
    default = true

}

resource "provider_vm "instance" {
    ...
    count = var.is_dev == true ? 2 : 5
}
```

#### Local values

in same module, we can use the locals to define local variables to be used in current module.
Supports conditional expression

What is the difference to global vars?

```hcl
locals {
    common_tags {
        key = "value"
        key2 = "value2
    }
}
```

#### Terraform functions

Terraform has a lot of **builtin functions**, no custom can be made
Syntax: ```max(1, 2, 3)```
One example: ```lookup(var.sku, var.region)```

one good function to know is the ```file("${file.path}/file_name")``` which returns the content of the file as a string
another one is ```timestamp()```

**OBS:** terraform has the ```terraform console``` command, that we can use to test those functions

!!!! TEst few!

#### Data sources

data to be fetched from somewhere to be used by Terraform. For that, we make use of the ```data {}``` block
For example, found [here](https://www.terraform.io/docs/language/data-sources/index.html):

**QUESTION:** do we have the same for azure? where we can see which ubuntu images we have, windows server, etc?
    * does not seem like it, was unable to find it

```hcl
data "aws_ami" "example" {
  most_recent = true

  owners = ["self"] ## Here, we could use amazon instead of self if we wanted images from amazon
  tags = {
    Name   = "app-server"
    Tested = "true"
  }
}
```

#### DEBUG in Terraform

the logs from terraform commands can be changed by setting the ```TF_LOG``` environment variable with one of the following values:
* TRACE, DEBUG, INFO, WARN or ERROR

**QUESTION:** from the logs, I can see .terraformrc, what is this file??
    * This file is responsible for changing the behaviour of the CLI as well as declare the TF Cloud and Enterprise credentials

**TEST:** put TF_LOG to TRACE and run a simple plan to understand the Terraform flow

Also, we can make use of the ```TF_LOG_PATH``` variable to store the log into a file somewhere

**TEST:** try to run terraform in Jenkins with those environment variables, as well as cache the plan

#### Terraform formatting and validation

Terraform has the ```terraform fmt``` command that helps aligning the indentation, making it easy to read files, which is called _canonical format and style_ .
Also, like any other big tools (helm, nginx, apache, etc), we have a way to validate the syntax of a file. For that, we make use of the ```terraform validate```.
It will validate un-asigned variables as well.

To run the validation, the currect dir must've been initialized already.

**QUESTION:** I suppose the best practise when changing the file, is to put a pre-commit(?) git hook that runs fmt and validate??
**TEST:** try above question.

Also, I imagine that ```terraform plan``` does, besides the ```terraform refresh```, the ```terraform validate``` as well


#### Load Order & Semantics

Load of .tf or .tf.json files happens in lexical order.

This is good to organize the TF modules. We can have the provider.tf that declares the provider, the variables.tf that will have the variables and so on...

resource_type.resource_name must be unique accross all read files.

### Dynamic blocks

the challenge is having a security group with N ingress rules, how to achieve it?

```hcl
dynamic "ingress" {
    for_each = var.ingress_ports

    content {
        from_port = ingress.value
        to_port = ingress.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
```

where those vars are

```hcl
variable "sg_ports {
    type = list(number)
    default = [8200, 8201, 8300, 9200, 9500]
}

```

#### Taint resources in Terraform

Terraform taint marks a terraform-managed resource as tainted, forcing it to be destroyed and recreated on the next apply

```terraform taint provider_resource.resource_name```

this will put a taint status in the state file, which is then removed after terraform apply


#### Splat expression

Allow us to retrieve a list of all attributes of a resource

For that, in the _output block_ we can reference all indexes of a list

#### Terraform Graph

The ```terraform graph > terraform.dot ``` can be converted into a graph image (can be use graphviz).
This then will generate an image that will show the terraform resources dependencies

#### Saving plans to a file

```terraform plan -out=planX``` and to apply ```terraform apply planX ```

The generated file is a binary file

#### Terraform output

with ```terraform output output_block_name``` we can get the output of an output block from .tf file once its applied.

#### Terraform settings

We can configure terraform in code as well, using the block

```hcl
terraform { 
    required_version = "> 0.12.0"   ### This will make sure that the config will only run if this matches
    required_providers {            ### Will define which provider needs to be used
        blabla = {
            source = '...'
            version = '...'
        }
    }

    ...

}
```

#### Dealing with large infrastructure

We might face issues regarding API limits for a provider (Terraform make API calls to create the resources)

If we run _terraform plan_ alone, it will make several api calls just to update the current state of the resources.

The best way to handle this is, instead of having a huge file with all resources, have separate folders for different resources/purposes and plan in each of them, one at a time.

Also, the terraform refresh can be ignored when planning if we add the flag _-refresh=false_ flag
Another way to avoid multiple API calls, we can also target a specific resource with the _-target=resource_ flag, instead of all the resources.
Those flags can be use at the same time.

Those flags are not to be used in production!

**OBS:** we can run ```terraform apply -auto-approve``` to accept the confirmation terraform requires.

#### Zipmap function

Construcs of map from a list of keys and corresponding of values (like the zip from python)

zipmap(['1', '2', '3'], ['z', 'x', 'y']) =
{
    '1': 'z',
    '2': 'x',
    '3': 'y'
}

#### Terraform State

The state is used to dimish the required complexity of checking what is the real infrastructure state.
Terraform expects each remote object to be bounded to only one resource instance - if we don't change the state manually, this is automatically achieved. We could change state by importing stuff into it - using the command ```terraform import```, and then, making sure we have a corresponding resource mapping it.

The state file can also hold dependency information because, imagine the following; The .tf files were deleted and we only have the state. To destroy the objects, terraform must know the proper order. Therefore, latest dependency is tracked in the state file as well.

Besided metadata and mappings from resources to actual provider objects, we must take into consideration the **performance**. For that terraform uses the cached state.

The default name is _terraform.tfstate_ and is stored locally. Yet, it can be stored remotely.
The first command terraform runs is the refresh, to update the state with the real infrastructure.

**Workspaces** are places where a persistent data stored in a backend belongs to.
Workspaces are good to logically isolate groups of resources.

Also, we can have a workspace for testing purposes, to make sure all changes in the .tf files are ok.

Terraform state can contain **sensitive data**. If stored remotely, it can be encrypted at rest BUT depends on the specified backend.
_Terraform Cloud_ encrytps state at rest and uses TLS in transit. Also S3 supports encryption at rest.

**TEST:** Try to store the state file remotely in azure storage!!!
