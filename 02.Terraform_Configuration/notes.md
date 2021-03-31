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

OBS: terraform has the ```terraform console``` command, that we can use to test those functions

!!!! TEst few!

#### Data sources

data to be fetched from somewhere to be used by Terraform. For that, we make use of the ```data {}``` block
For example, found [here](https://www.terraform.io/docs/language/data-sources/index.html):

QUESTION: do we have the same for azure? where we can see which ubuntu images we have, windows server, etc?

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

QUESTION: from the logs, I can see .terraformrc, what is this file??

TEST: put TF_LOG to TRACE and run a simple plan to understand the Terraform flow

Also, we can make use of the ```TF_LOG_PATH``` variable to store the log into a file somewhere

TEST: try to run terraform in Jenkins with those environment variables, as well as cache them in the pipeline(?) to be available at each build

#### Terraform formatting and validation

Terraform has the ```terraform fmt``` command that helps aligning the indentation, making it easy to read files, which is called _canonical format and style_ .
Also, like any other big tools (helm, nginx, apache, etc), we have a way to validate the syntax of a file. For that, we make use of the ```terraform validate```.
It will validate un-asigned variables as well.

To run the validation, the currect dir must've been initialized already.

QUESTION: I suppose the best practise when changing the file, is to put a pre-commit(?) git hook that runs fmt and validate??
TEST: try above question.

Also, I imagine that ```terraform plan``` does, besides the ```terraform refresh```, the ```terraform validate``` as well


#### Load Order & Semantics

Load of .tf or .tf.json files happens in lexical order.

This is good to organize the TF modules. We can have the provider.tf that declares the provider, the variables.tf that will have the variables and so on...

resource_type.resource_name must be unique accross all read files.