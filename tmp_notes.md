## Provisioners

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

#### DRY Principle