variable "name" {
  default = "terraform-example"
}

resource "alicloud_cr_ee_instance" "example" {
  payment_type   = "Subscription"
  period         = 1
  renew_period   = 0
  renewal_status = "ManualRenewal"
  instance_type  = "Basic"
  instance_name  = var.name
  custom_oss_bucket = "acrbucket"
}

resource "alicloud_cr_ee_namespace" "example" {
  instance_id        = alicloud_cr_ee_instance.example.id
  name               = var.name
  auto_create        = false
  default_visibility = "PUBLIC"
}

resource "alicloud_cr_ee_repo" "example" {
  instance_id = alicloud_cr_ee_instance.example.id
  namespace   = alicloud_cr_ee_namespace.example.name
  name        = var.name
  summary     = "this is summary of my new repo"
  repo_type   = "PUBLIC"
  detail      = "this is a public repo"
}

resource "alicloud_ram_role" "AliyunContainerRegistryCustomizedOSSBucketRole" {
  name = "AliyunContainerRegistryCustomizedOSSBucketRole"
  document = <<EOF
    {
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Effect": "Allow",
          "Principal": {
            "Service": [
              "cr.aliyuncs.com"
            ]
          }
        }
      ],
      "Version": "1"
    }
EOF
  description = "this is a role test."
  force       = true
}

resource "alicloud_ram_policy" "AliyunContainerRegistryCustomizedOSSBucketRolePolicy" {
  policy_name     = "AliyunContainerRegistryCustomizedOSSBucketRolePolicy"
  policy_document = <<EOF
    {
        "Statement": [
            {
                "Action": "oss:*",
                "Effect": "Allow",
                "Resource": "*"
            }
        ],
        "Version": "1"
    }
EOF
  description     = "this is a policy test"
  force           = true
}

resource "alicloud_ram_role_policy_attachment" "attach" {
  policy_name = alicloud_ram_policy.AliyunContainerRegistryCustomizedOSSBucketRolePolicy.policy_name
  role_name   = alicloud_ram_role.AliyunContainerRegistryCustomizedOSSBucketRole.name
  policy_type = alicloud_ram_policy.AliyunContainerRegistryCustomizedOSSBucketRolePolicy.type
}


# 使用Terraform为OSS（对象存储服务）创建一个RAM用户并授权，以便为镜像服务提供访问
# resource "alicloud_ram_user" "oss_user" {
#   name     = "oss_user_for_image_service"
#   comments = "用于镜像服务的OSS访问用户"
# }
 
# resource "alicloud_oss_bucket" "image_service_bucket" {
#   bucket = "image-service-bucket"

# }
 
# resource "alicloud_oss_bucket_policy" "oss_ucket_policy" {
#   bucket = alicloud_oss_bucket.image_service_bucket.id
#   policy = <<POLICY
#     {
#         "Statement": [
#             {
#                 "Action": "oss:*",
#                 "Effect": "Allow",
#                 "Resource": "*"
#             }
#         ],
#         "Version": "1"
#     }
#     POLICY
# }


# # Create a RAM Role Policy attachment.
# resource "alicloud_ram_role" "AliyunContainerRegistryCustomizedOSSBucketRole" {
#   name        = "roleName"
#   document    = <<EOF
#     {
#         "Statement": [
#             {
#                 "Action": "sts:AssumeRole",
#                 "Effect": "Allow",
#                 "Principal": {
#                     "Service": [
#                         "cr.aliyuncs.com"
#                     ]
#                 }
#             }
#         ],
#         "Version": "1"
#     }
#     EOF
#   description = "this is a role test."
# }

# resource "random_integer" "default" {
#   min = 10000
#   max = 99999
# }

# resource "alicloud_ram_policy" "policy" {
#   policy_name     = "tf-example-${random_integer.default.result}"
#   policy_document = <<EOF
#     {
#     "version": "1",
#     "statement": [
#         {
#         "effect": "Allow",
#         "action": [
#             "oss:GetObject",
#             "oss:PutObject"
#         ],
#         "resource": ["acs:oss:*:*:image-service-bucket", "acs:oss:*:*:image-service-bucket/*"],
#         "principal": ["acs:ram::*:user/${alicloud_ram_user.oss_user.name}"]
#         }
#     ]
#     }
#   EOF
#   description     = "this is a policy test"
# }

# resource "alicloud_ram_role_policy_attachment" "attach" {
#   policy_name = alicloud_ram_policy.policy.policy_name
#   policy_type = alicloud_ram_policy.policy.type
#   role_name   = alicloud_ram_role.role.name
# }