#### Handling user and secrets

Never put credentials directly into .tf files

Use the CLI and login, then terraform is able to use it to work, by using in ~/.azure or ~/.aws credentials.

#### Provider configuration

We can use the ```alias``` to have multiple provider configurations and then reference that alias for resources that should follow that provider configuration

```hcl
provider "aws" {
    region = 'bla'
    alias = 'pops'
}

resource 'aws_eip' 'example' {
    ...
    provider = aws.pops
}
```

#### Profiles

In the providers, we can also use ```profile``` to create resources in different accounts

```hcl
provider "aws" {
    ...
    ...
    profile = "account02" ### this is taken from ~/.aws cred
}
```

#### Terraform with STS (Assume rule)

This can be achieved with some sort of delegation.

```hcl
provider "aws" {
    region = "aa"
    assume_role { 
        role_arn = ..............
    }
}
```

#### Sensitive parameter

This will hide the value of the output by the ```plan/apply```, yet, in the state file this will still be plain text

```hcl
output "" {
    sensitive = true
}
```