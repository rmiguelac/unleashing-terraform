## Remote State Management

#### The challenge of storing files remotely

When username and password must be provided, we cannot push it to git. \
For that, we can create a pass file and use the file() function and not commit that file, yet this is not the best approach.

!!!! terraform.tfstate has password in plain text, do not put in git

#### Few files to consider ignoring when pushing to git

* .terraform dir (this is big)
* terraform.tfvars (might have users/passwords)
* terraform.tfstate (most likely will have users/passwords)
* crash.log
* .terraformrc as well ?

#### Terraform module sources

inside a module, there is the _source_ declaration, that defines where to take the module from. The source accepts several types, such as

* local path
* terraform registry
* github / bitbucket / generic git / mercurial
* http urls
* s3 buckets
* GCS buckets

**QUESTION:** does it accept azure storage?

for example (both https and ssh are supported for git):

```hcl
module "vpc" { 
    source = "git::https://..../.vpc.git"
}
```

we can change the ref to pull the branch/tag by using ref=1.2.3


```hcl
module "vpc" { 
    source = "git::https://..../.vpc.git?ref=1.2.0"
}
```

be aware that the repo will be cloned inside .terraform/modules

#### Remote backend

to defined backends use the terraform { backend "" {} }

```hcl
terraform {
    backend "s3" {
        bucket = ""
        key = ""
        region = ""
        access_key = ""
        secret_key = ""
    }
}
```

Also, initialize the terraform backend by running the ```terraform init```
For more information, visit [this](terraform.io/docs/backends/types)

There are 2 major types of backend types:

* Standard - state storage and locking
* Enhanced - Standard + remote management

When using a backend, terraform will pull and push the terraform.tfstate to the backend 

#### State locking

Write operations lock the state file as two simulatenous writes could corrupt the file (terraform plan does write operations)

**OBS:** s3 backend does not support _state locking_ by default, we must use dynamoDB for locking purposes - read the docs
**QUESTION:** how do I check if the backend supports _state locking_?
    * Read the documentation of the backend [Backends](https://www.terraform.io/docs/language/settings/backends/azurerm.html#)
**QUESTION:** does azure backend support _state locking_ ?
    * [Yes](https://www.terraform.io/docs/language/settings/backends/azurerm.html#)

#### State Management - state CLI

the terraform offers several state commands:

* ```terraform state list```
    shows one resource at a time/line that are in the state file

* ```terraform state mv```
    used to rename existing resources or relocate them
    due do destructive nature of this command, a backup copy of the prior state is output
    ```terraform state mv [options] SOURCE DESTIONATION```
    to rename: ```terraform state mv aws_instance.webapp aws_instance.myec2``` - this does not change the .tf files

* ```terraform state pull```
    pulls (downloads) the state from remote backend and prints its content

* ```terraform state push```
    manually upload a local state file to remote state

* ```terraform state rm```
    remove resource from state file
    This will not destroy the resorce
    Terraform will not handle the resource anymore
    If we still reference the resource in .tf files, it will be recreated

* ```terraform state show```
    show attributes of a single resource
    example: ```terraform state show aws_iam_user.lb```

#### Terraform import

Used to import into terraform if resources are created prior to terraform adoption. Can also be used when someone creates resources manually
Import only do so in the state file, meaning that the .tf file must be written in any case [doc](https://www.terraform.io/docs/cli/import/index.html). For this reason, prior to running terraform import, we must have the .tf resource definitions to which the imported object will be mapped.
Imports only one resource at a time.
Not all terraform resources are currently importable.

to import into resource ```terraform import aws_instance.foo i-abcd1234```

to import into resource with count ```terraform import 'aws_instance.baz[0]' i-acbd1234```

to import into module ```terraform import module.foo.aws_instance.bar i-abcd1234```




