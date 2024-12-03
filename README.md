# azure-egress
Materials to deal with Azure egress use cases

This Terraform code is deploying the necessary infrastructure to monitor Azure egress scenarios. It includes resources such as virtual networks, subnets, network security groups, and route tables to control and monitor outbound traffic from Azure resources.

Users can browse to the monitoring VM to see the egress IPs from each subnet.

The goal is then to apply different egress method to see the behavior on egress IP used.

Monitoring VM queries each subnet's VM for egress IP and display a summary over http on port 80. Use to output of deployment to click the link.
