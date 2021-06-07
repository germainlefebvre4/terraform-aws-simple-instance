
resource "aws_key_pair" "ssh" {
  key_name   = "germain-ineat-rsa-key-20181112"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgEAt8KrzIOaCmtQAzSpwiPoFdO3Ctvhnnq78CxJaH88noK/UA0fj9lMw7KYCRWJz9/1rwBHWNHfJxuKS4qdcipFrOxFG+9MF6sfzKjml8qNVsXPc/TnUUKFndgmngkcLj0ft7mqtDLVnm409EVuCwvrQ8yTUjAmaeJrhudLVW/JEn9jV3AjwTm0K0BYZiAs+URv+CX3f8S/YqKaIUxQTutC1iMvkcz/kzguX8RWeYlxAC3IHUZVzQtZ/7pZE3ZKxaWuYXR6Hgez0ykRI3kbeXwS31EXs5YFfWEaseuJuvUR3hT/R02nbbgAiBj3ydSxL09KuMCWi685mkujg3KMorYwJlFn0gK0zEe1D0UpVc9gd+8viaV+SWNvs91G0DlQbqO6XID22J2WoeVF7Q61RWBWV9PzPmXG9oHXSNe2dEATkfRE+vYCrg2mFi8RYuyhNJdamfIVDL1xn7Cv8l6VPvBrYe8pFBoy6FBK+PnheSHfzTX+WLdC8TMgqix92lwtSNx7aTPuC4zyYUgucy2K+zMPYrpDEnTt6VgcxZ2ZKKHKYc9RmaqNRi2VujqVFH5VcDWdTnWw6B0jtRjXyr2Nz5vgPAVaPKm4kZoZE5J34GSueAsX6lwsHMNahYY7Kss/2GHOXZr12h5/WkE5eq4F2jaFOojG+2lZ5Y9/TqK9IAlAtvM= germain-ineat-rsa-key-20181112"
}

data "aws_ami" "ami" {
  most_recent = true

  owners = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["CentOS*Linux*7*x86_64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "lc_user_data" {
  template = "${file("${path.module}/templates/lc_instance.sh")}"
  vars = {
    name = "launchConfig"
    ssh_key = "to to to"
    ssh_keys = "${join(" ", var.ssh_keys)}"
  }
}

resource "aws_instance" "instance" {
  depends_on = [aws_key_pair.ssh, aws_security_group.ssh]

  count = 1

  ami           = data.aws_ami.ami.id
  instance_type = "t3.medium"

  key_name = aws_key_pair.ssh.key_name

  user_data = data.template_file.lc_user_data.rendered

  security_groups = ["default", aws_security_group.ssh.name]
  
  root_block_device {
    volume_size = 40
    delete_on_termination = true
  }

  tags = {
    Name = "simple-instance-${count.index + 1}"
    Author = "terraform"
    Project = "germain"
    Environment = "poc"
  }
}

resource "aws_security_group" "ssh" {
  name        = "simple-instance-ssh"
  description = "SSH Access"

  tags = {
      Name = "simple-instance-ssh"
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  security_group_id = aws_security_group.ssh.id

  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  cidr_blocks              = ["46.29.126.206/32", "185.161.45.231/32", "81.254.54.89/32", "92.184.116.157/32", "0.0.0.0/0"]
}


resource "aws_security_group_rule" "allow_http" {
  security_group_id = aws_security_group.ssh.id

  type                     = "ingress"
  from_port                = 80
  to_port                  = 10000
  protocol                 = "tcp"
  cidr_blocks              = ["46.29.126.206/32", "185.161.45.231/32", "81.254.54.89/32", "92.184.116.157/32", "0.0.0.0/0"]
}

output "dns" {
    value = aws_instance.instance.*.public_dns
}
output "ami" {
    value = data.aws_ami.ami.name
}
output "ssh" {
    value = "${join(" ", var.ssh_keys)}"
}
