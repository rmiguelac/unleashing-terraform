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