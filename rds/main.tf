
provider "alicloud" {
  region = "cn-beijing"
}

data "alicloud_db_zones" "example" {
  engine           = "PostgreSQL"
  engine_version   = "14.0"
  instance_charge_type     = "PostPaid"
  category                 = "HighAvailability"
  #multi_zone = true
}



resource "alicloud_vpc" "example" {
  vpc_name       = "alicloud"
  cidr_block = "172.16.0.0/16"
}

resource "alicloud_vswitch" "example" {
 
  vpc_id       = alicloud_vpc.example.id
  cidr_block   = format("172.16.%d.0/24", 0)
  zone_id      = "cn-beijing-i"
  vswitch_name = format("%s_%d", "alicloud-v", 0)
}
resource "alicloud_vswitch" "example1" {
 
  vpc_id       = alicloud_vpc.example.id
  cidr_block   = format("172.16.%d.0/24", 1)
  zone_id      = "cn-beijing-l"
  vswitch_name = format("%s_%d", "alicloud-v", 1)
}
resource "alicloud_db_instance" "instance" { 
   engine           = "PostgreSQL"
  engine_version   = "14.0"
  instance_type    = "pg.n2.2c.2m"
  instance_storage = "30"
  instance_charge_type = "Postpaid"


  category                 = "HighAvailability"
  
  
  vswitch_id               = join(",", alicloud_vswitch.example.*.id)
  monitoring_period        = "60"
  db_instance_storage_type = "cloud_essd"
  zone_id                  = "cn-beijing-i"
  zone_id_slave_a          = "cn-beijing-l"

  sql_collector_status = "Enabled"

  lifecycle {
    create_before_destroy = true
  }
 
}