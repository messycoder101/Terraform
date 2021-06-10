Basic infrastructure is almost ready.

**main.tf** has some isssues to be sorted out.
1. Load Balancer module, named **tfLB** requires subnets in different Availability Zones --need to figure out how to configure the same.
2. Need to update subnet modules to include availability zones as well.
3. need to encrypt all data  at rest.
4. configure ASG to automatically add n remove nodes as per load.
