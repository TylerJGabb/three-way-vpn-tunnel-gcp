locals {
  shared_secret = "shared_secret"

  # the interface IPs must be in the same /30 CIDR block in the link local space
  # it is misleading that the terraform resource name is "ip_range,", so I've 
  # generalized it to "ip" in the local variable name, tacking on the CIDR block
  a-to-b-interface-1-ip = "169.254.0.1"
  b-to-a-interface-1-ip = "169.254.0.2"

  a-to-b-interface-2-ip = "169.254.2.1"
  b-to-a-interface-2-ip = "169.254.2.2"
}
