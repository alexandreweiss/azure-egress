variable "location" {
  description = "Location of resource deployed"
  default     = "France Central"
}

variable "location_short" {
  description = "Short for location"
  default     = "frc"
}

variable "lab_cidr" {
  description = "CIDR used for the lab"
  default     = "10.33.0.0/16"
}

variable "subnet_count" {
  description = "Number of subnet in vnet"
  default     = 2
}

variable "subscription_id" {
  description = "Azure subscription ID to deploy resource to"
}

variable "admin_ssh_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQBsUy8OllCkhpOU4FplN1b7ypawC/8QM++3gb9EbqZHCJnJdTNhk/0QZVvGsPvWeSazsShgX2TdEMMdDFscWDdAfnoB+hyjhFyWaOfKXFdzafib3HrO0rGUPqW42V6d0N2V5rh23ZFZGX5Bp75KEFnrFgGY1axCebvMvStGzXXffole1sCt0SKbvFptc/MT/ZVSqT0i0ugS0dVXsb4kuo4qnNRUAqvunljDL5oS3ZT7bQtjAvcw+IyYF6Ka9pGc4EuNaYZ2YuaxMyMOKYoMq4Qz8Qk5oF34ATGCPC0SdAgtAByNblbYeB6s+ueWUwSEcKOfIKjl9lxJasCRBRkjl7zp non-prod-test"
}
