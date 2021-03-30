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