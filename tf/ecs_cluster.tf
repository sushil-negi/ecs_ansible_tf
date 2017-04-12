resource "aws_ecs_cluster" "atb-atlassian" {
  name = "${var.ecs_cluster_name}"
}

/**
 * Launch configuration used by autoscaling group
 */
resource "aws_launch_configuration" "ecs-atlassian-alc" {
  name                 = "ecs-atlassian-alc"
  image_id             = "${lookup(var.amis, var.region)}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.key_name}" 
  iam_instance_profile = "${aws_iam_instance_profile.ecs.id}"
  security_groups      = ["${aws_security_group.ecs.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ecs.name}"
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.atb-atlassian.name} > /etc/ecs/ecs.config"
}

/**
 * Autoscaling group.
 */
resource "aws_autoscaling_group" "ecs-atlassian-asg" {
  name                 = "ecs-atlassian-asg"
  availability_zones   = ["${split(",", var.availability_zones)}"]
  launch_configuration = "${aws_launch_configuration.ecs-atlassian-alc.name}"
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  desired_capacity     = "${var.desired_capacity}"
  
  tag {
    key = "Name"
    value = "ATB-Atlassian-ALC"
	propagate_at_launch = true
  }

}

/*
resource "aws_security_group" "load_balancers" {
    name = "ecs-atlassian-lb-sg"
    description = "Allows all traffic"
    #vpc_id = "${aws_vpc.main.id}"

    # TODO: do we need to allow ingress besides TCP 80 and 443?
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # TODO: this probably only needs egress to the ECS security group.
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

  tags {
    Name ="ecs-atlassian-lb-sg"
  }
}

*/

resource "aws_security_group" "ecs" {
    name = "ecs-atlassian-sg"
    description = "Allows all traffic"
/*    vpc_id = "${aws_vpc.main.id}"
*/
    # TODO: remove this and replace with a bastion host for SSHing into
    # individual machines.
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

/*    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = ["${aws_security_group.load_balancers.id}"]
    }
*/
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
  tags {
    Name ="ecs-atlassian-sg"
  }
}

resource "aws_iam_role" "ecs_host_role" {
    name = "ecs_host_role"
    assume_role_policy = "${file("policies/ecs_role.json")}"
}

resource "aws_iam_role_policy" "ecs_instance_role_policy" {
    name = "ecs_instance_role_policy"
    policy = "${file("policies/ecs_instance_role_policy.json")}"
    role = "${aws_iam_role.ecs_host_role.id}"
}

resource "aws_iam_instance_profile" "ecs" {
    name = "ecs-instance-profile"
    path = "/"
    roles = ["${aws_iam_role.ecs_host_role.name}"]
}