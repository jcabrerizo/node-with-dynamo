
# Cloudsoft AMP - Maeztro for Terraform Tutorial

Welcome. This tutorial will walk you through the key concepts behind Cloudsoft AMP, using the Maeztro subsystem so we can very quickly get a working application blueprint and learn how AMP provides a structured approach to management. You will first see a sample application, using both cloud VMs and services, deployed with Terraform. The application has a few bugs that impact operations, so we will use Maeztro to collect information on the problems and then resolve them operationally.

The tutorial will take about an hour, and the techniques you will learn will apply to any Terraform deployments where you want to simplify and blueprint operations.  


## Prerequisites

This tutorial assumes that:

* This project checked out to a folder (if not, `git clone https://github.com/cloudsoft/node-with-dynamo.git` now)
* You have access to a running AMP with Maeztro, such as in a Docker container, Kubernetes, or hosted
* You have AWS credentials -- an access key and secret key -- with permissions to: provision EC2 resources, use DynamoDB, and view CloudWatch metrics
* You have `terraform` installed on the CLI on the machine where this project is checked out


## What You'll See

In [section 1](1-terraform.md), the tutorial will first deploy a simple application using Terraform.

In [section 2](2-grouping.md), we will import the applications into Maeztro and group the Terraform resources to reflect the application's **topology** the make the resources easier to work with.

In [section 3](3-sensors.md), **sensors** will be defined to collect useful information to explore an issue.

In [section 4](4-effectors.md), **effectors** will be written to perform operations to resolve the issue.

In [section 5](5-policies.md), we will write **policies** to resolve the issue automatically as soon as it starts to impact performance. 

Each section should take between 5 and 15 minutes.  


## Get Started

Get started with [section 1 -- deploying the app with Terraform](1-terraform.md).
