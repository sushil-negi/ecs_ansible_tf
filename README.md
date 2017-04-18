# ecs_ansible_tf
In order to use terraform with this repo, you would need to include

1. secrets.tfvars in your local with two variables
    aws_access_key_id="<aws_access_key_id>"
    aws_secret_access_key="<aws_secret_access_key>"
2. Alternatively you can also set above to variables in your environment if you prefer.

Performing step #1 or #2 will setup your environment to connect with AWS.

Secondly, you will now need to setup terraform.tfvars file with following variables

    ecs_cluster_name = "<pick a name>"  - a name that you want to see in AWS for your cluster
    instance_type = "t2.large"          - any size that is supported by AWS

#add input variables if you need additonal containers

    atb_jira = 1                        - this is a boolean value, if 1 it will create JIRA
    atb_confluence = 1                  - this is a boolean value, if 1 it will create Confluence
    atb_bamboo = 0                      - this is a boolean value, if 0 it will create bamboo

if you want additonal containers, say like jenkins, then you would create another value like
atb_jenkins = 1 to make this happen, ofcourse a container support will also be needed in the code for that. Look for comments in the code to find where to add the support for additonal containers.

Below variables will decide what your desired values for the container host is. With below example, if auto scaling happens, the max # of instances scaled up to would be 5, However a minimal of 2 containers will always be there to support our infrastructure needs.

    min_size = 2
    max_size = 5
    desired_capacity = 2

when doing Jenkins automation, we can create a terraform.tfvars as an output to feed into terraform automation.
