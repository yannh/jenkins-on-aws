# Jenkins on AWS - An opinionated guide

[![Build Status](https://travis-ci.org/yannh/jenkins-on-aws.svg?branch=master)](https://travis-ci.org/yannh/jenkins-on-aws)

There are many ways to deploy Jenkins on AWS, in this case we are using:
 * Packer and Puppet to create AMIs
 * Cloudformation to build the Stack
 * The EC2 plugin to automatically create slaves
 * Docker to build software
 * Lambda functions to handle snapshot backups / backup cleaning

This is currently a work in progress derived from an existing, more
complex production setup. It is shared for instructional purposes.

## Concepts

Packer and Puppet help create a largely immutable cluster. The state
is concentrated in /var/lib/jenkins on the Jenkins Master, which is
isolated on a separate EBS volume.
The volume is snapshotted daily, and there is a lambda function to clean
old backups regularly. It is possible to recreate or clone the whole
cluster given a snapshotId, and some minor reconfiguration.

The template creates an appropriate IAM role for the Jenkins Master
instance to allow the usage of the Jenkins EC2 plugin, which will
dynamically create the slaves.

The slaves are very simple Ubuntu AMIs with Docker installed - jobs
should use docker to run the builds. Example dockerfiles are given
in the docker/ folder.

An ELB is created that can be used for SSL termination.

## Requirements

To Setup Jenkins on AWS you will need librarian-puppet and packer setup.

## Create the AMIs

Install the Puppet modules:

    (cd puppet && librarian-puppet install)

Create the AMIs:

    export AWS_ACCESS_KEY=YOUR_ACCESS_KEY
    export AWS_SECRET_KEy=YOUR_SECRET_KEY
    PROFILE=master packer build packer/jenkins-ami.json
    PROFILE=slave packer build packer/jenkins-ami.json

## Building the Docker images

There are samples Dockerfiles in the docker/ folder, to build:

    docker build -f docker/ubuntu-xenial-nodejs .
