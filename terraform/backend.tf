terraform {
  backend "s3" {
    bucket = "terraform-state-bucket04"
    key = "dev/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
  }

}