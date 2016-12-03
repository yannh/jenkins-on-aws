# Jenkins on AWS - An opinionated guide (WIP)

There are many ways to deploy Jenkins on AWS, in this case we are using:
 * Packer and Puppet to create AMIs
 * Cloudformation to build the Stack
 * The EC2 plugin to automatically create slaves
 * Docker to build software

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

## Create the Cloudformation stack
