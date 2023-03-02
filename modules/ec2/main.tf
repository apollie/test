resource "aws_instance" "ec2_instance" {
  count = var.instance_count
  availability_zone = var.az_list[count.index % 3]
  ami = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.subnet_id[count.index % 3]
  vpc_security_group_ids = var.security_group

  key_name = aws_key_pair.my_key.id

  tags = {
    Name = format("%s%03d", var.prefix, count.index + 1)
    index = count.index + 1
    count = var.instance_count
  }

  metadata_options {
    instance_metadata_tags = "enabled"
    http_endpoint = "enabled"
  }
    connection {
        host  = self.public_ip
        type  = "ssh"
        user  = "ec2-user"
        private_key = file(var.private_key)
        agent = true
    }
    provisioner "file" {
        source      = "files/ping.sh"
        destination = "/home/ec2-user/ping.sh"
    }
}

resource "null_resource" "upload" {
    count = var.instance_count
    connection {
        host  = aws_instance.ec2_instance[count.index].public_ip
        type  = "ssh"
        user  = "ec2-user"
        private_key = file(var.private_key)
    }
    provisioner "remote-exec" {
        inline = [
        "chmod +x /home/ec2-user/ping.sh",
        "/home/ec2-user/ping.sh",
        "exit 0"
        ]
    }
    depends_on = [aws_instance.ec2_instance,aws_route53_record.vm]
    triggers = {
        always_run = "${timestamp()}"
    }
}

resource "null_resource" "file" {
    count = var.instance_count
    connection {
        host  = aws_instance.ec2_instance[count.index].public_ip
        type  = "ssh"
        user  = "ec2-user"
        private_key = file(var.private_key)
    }
    provisioner "remote-exec" {
        inline = [
            "cat /home/ec2-user/ping.results"
        ]
    }
    depends_on = [null_resource.upload]
    triggers = {
        always_run = "${timestamp()}"
    }
}

resource "aws_key_pair" "my_key" {
  key_name   = "my_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUtMXKNGRjmkIVXiZcOJA8fMeOA+E8WEMwzqscgfm51Fkoo3tbBc2O00h7WRI0Pt3X/gjCk0NhDvhvNSxJUxc/txER9yt0H6vc28/FRIHNzQjvtavv4gu0qBiVLndcg8oB5ViiUydhhQCWm/iRlzmF04ZUSnkrzddWSENpHos2U4oZ/lBb+ifE/arJnI+SGeR9hrQ5PvpyoISBiZ7ZamQHxWodR5rMSTujmqipkV07t8xwJtvFVnA5H8mAuIrIJ5RAv6O4Xq+6a065+cNEYGJqtYVlj2ahFlJ5xIHEQqCrxp6vpBitUA7pFVE2G2SNRNt83uETDsAmvuMV6IryKKc7"
}

resource "aws_route53_zone" "private" {
  name = "${var.prefix}-zone.com"

  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "vm" {
  count = var.instance_count
  zone_id = aws_route53_zone.private.zone_id
  name    = format("%s%03d", var.prefix, count.index + 1)
  type    = "A"
  ttl     = 10
  records = [aws_instance.ec2_instance[count.index].public_ip]
}

