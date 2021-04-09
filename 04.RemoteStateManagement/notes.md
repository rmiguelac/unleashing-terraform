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

**TASK:** Implement something using a backend from azure

There are 2 major types of backend types:

* Standard - state storage and locking
* Enhanced - Standard + remote management

When using a backend, terraform will pull and push the terraform.tfstate to the backend 

#### State locking

Write operations lock the state file as two simulatenous writes could corrupt the file (terraform plan does write operations)

**OBS:** s3 backend does not support _state locking_ by default, we must use dynamoDB for locking purposes - read the docs
**QUESTION:** how do I check if the backend supports _state locking_?
**QUESTION:** does azure backend support _state locking_ ?

