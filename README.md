# terraform_web_mysql_project
simple web application deployment on EC2 server with MySQL server database using terraform

This project involves provisioning cloud resources using Terraform to set up a basic web application infrastructure with the components,
1. An AWS EC2 instance running a basic web server
2. An AWS RDS MySQL database for storing application data

*Prerequisites*

    Terraform installation (Version: 1.8.3)
    AWS CLI(version 2)
    AWS credentials configured (~/.aws/credentials)
    Visual Studio Code

*Explaination*

The main project folder is terraform_challenge.

Folder consists of different .tf files with explaination given below,

1. provider.tf -> A provider in terraform is a plugin that enables interaction with an API that indicates Cloud providers(AWS/GCP/Azure) with the region & its statefile.
2. main.tf -> The main.tf file is the starting point to implement the logic of infrastructure as code. This file will include Terraform resources, but it can also contain datasources and locals. Here resource creation of VPC, subnet, Route tables and it association, Internet gateway , ubuntu EC2 instance for web application & MySQL database application, and the necessary components required for successful deployment. 
3. Varibales.tf -> Terraform variables allows to write configuration that is flexible and easier to re-use on multiple modules instead of hardcoding value on one place.
4. output.tf -> This file make it easier for users to understand configuration and review its expected outputs.

Commands used for provisioning the infrastructure:

1. Terraform init -> Initializes a working directory and downloads the necessary provider plugins and modules and setting up the backend for storing infrastructure's state.
2. Terraform validate -> It checks the syntax of the Terraform files, ensures the correct usage of attributes and values, and validates the configuration written.
3. Terraform apply --auto-approve -> This command will apply changes to the infrastructure on cloud provider without manual confirmation.
   
Once resources are created successfully on AWS, we will get output to the resource like shown in the figure,
![image](https://github.com/user-attachments/assets/574abd28-9995-4abd-b781-9f6be4020c88)

MySQL RDS database created and will be in available state like this,
![image](https://github.com/user-attachments/assets/7fa130b5-7a2a-4ef9-bb5c-19d68eeecad1)

After connecting to the particular EC2 instance ( nginx web server) , checking for the status of web server looks like this,
![image](https://github.com/user-attachments/assets/4a3dbccd-bf5d-4274-b854-7d24d137760a)

The final output where i can access nginx web application on the browser with Ipv4_address:port(http://13.234.255.53:80) will look with the message given on userdata script of EC2 instance.
![image](https://github.com/user-attachments/assets/78c40aa0-e3f6-423b-87d7-29b0566c14fb)

4. Terraform destroy -> This will clean up all the reources created on the AWS cloud provider to avoid incurring cost.
