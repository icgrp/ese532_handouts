# Getting Started on Amazon EC2
```{warning} Make sure to stop your Amazon instances! We only have
$150 of credits and we need it to last till Homework 7.
```
## Create an AWS account
by going to: <https://aws.amazon.com/>

## Email us your Account ID
We will need this to get you access to F1 instances, while you work
with A1 instances. Go to the following page and find your Account ID
```{image} images/aws_account_id.png
```

## Create and Launch an A1 instance
From the management console, click on ***Launch a virtual machine***:
```{image} images/launch_a1_1.png
```
---
Select ***Amazon Linux 2 AMI (HVM)*** as your AMI and make sure ***64-bit (Arm)***
is checked.
```{image} images/launch_a1_2.png
```
---
Select ***a1.large*** instance type and click on ***Review and Launch***
```{image} images/launch_a1_3.png
```
---
Select ***Launch*** on the current page. Create a key pair by giving a suitable
name and then selecting ***Download Key Pair*** (we will use this key to
ssh into the machine later). Now click on ***Launch Instance***.
```{image} images/launch_a1_4.png
```
---
You should see a screen as follows. Select ***View instances***.
```{image} images/launch_a1_5.png
```
---
Wait for your instance to be running. You can refresh the page by clicking
on the refresh button on the top right. Note down the ip address from the
bottom right.
```{image} images/launch_a1_6.png
```
---
On MacOS/Linux:
 - Open a terminal and ssh into your machine using your key pair and ip
 address
 ```
 ssh -i /path/to/key_pair.pem ec2-user@<ip address of your machine>
 ```
You should see a screen similar to the following:
```

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
4 package(s) needed for security, out of 8 available
Run "sudo yum update" to apply all updates.
[ec2-user@ip-172-31-41-240 ~]$
```
---
Execute the following commands. This will get the compiler necessary for
running homeworks 1-4.
```
sudo yum update -y
sudo yum groupinstall "Development Tools" -y
```
---
You are now ready to do homeworks 1-4!

```{warning}
Make sure to stop your Amazon instances! We only have
$150 of credits and we need it to last till Homework 7.

```{image} ../common/stop_warning.png

```
