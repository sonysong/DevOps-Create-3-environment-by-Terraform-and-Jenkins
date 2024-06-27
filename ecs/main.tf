provider "alicloud" {

	region = "cn-hangzhou"
}


variable "name" {
  default = "terraform-example"
}

# Create a new ECS instance for a VPC
resource "alicloud_security_group" "group" {
  name        = var.name
  description = "foo"
  vpc_id      = alicloud_vpc.vpc.id
}

data "alicloud_zones" "default" {
  available_disk_category     = "cloud_efficiency"
  available_resource_creation = "VSwitch"
}

# Create a new ECS instance for VPC
resource "alicloud_vpc" "vpc" {
  vpc_name   = var.name
  cidr_block = "172.16.0.0/16"
}

resource "alicloud_vswitch" "vswitch" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "172.16.0.0/24"
  zone_id      = data.alicloud_zones.default.zones.0.id
  vswitch_name = var.name
}



resource "alicloud_instance" "example" {

  instance_type              = "ecs.c7.large"
  image_id                   = "ubuntu_18_04_64_20G_alibase_20190624.vhd"
  instance_name              = "example"

  availability_zone = data.alicloud_zones.default.zones.0.id
  security_groups   = alicloud_security_group.group.*.id
vswitch_id                 = alicloud_vswitch.vswitch.id

  system_disk_category       = "cloud_essd"
  system_disk_name           = var.name
}

resource "alicloud_cloud_monitor_service_monitoring_agent_process" "default" {
  instance_id  = alicloud_instance.example.id
  process_name = var.name
  process_user = "root"
}
