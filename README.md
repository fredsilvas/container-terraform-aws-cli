# container-terraform-aws-cli

## Motivation

The goal is to create a minimalist and lightweight image with these tools in order to reduce network and storage impact.

This image gives you the flexibility to be used for development or as a base image as you see fits.


## What's inside ?

Tools included:
### AWS CLI

Included version indicated below

### Terraform CLI

Included version indicated below

### Git for Terraform remote module usage

Version: 2.20.1

### jq to process JSON returned by AWS

Version: jq-1.5-1-a5b5cbe

### OpenVPN to conect on private EC2 instances

Version: 2.4.7
## Usage

Launch the CLI

Set your AWS credentials (optional) and launch the container, using the tag:

```
echo AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
echo AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
echo AWS_DEFAULT_REGION=YOUR_DEFAULT_REGION

docker container run -it --rm -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" -v ${PWD}:/workspace container-terraform-aws-cli:<tag>
```

The --rm flag will completely destroy the container and its data on exit.


## Principal Tools Versions
- AWS cli: 2.1.38

- TERRAFORM: 0.15.0