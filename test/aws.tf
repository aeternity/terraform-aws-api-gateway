# Default
provider "aws" {
  region  = "us-east-1"
}

provider "aws" {
  region  = "ap-southeast-2"
  alias   = "ap-southeast-2"
}

provider "aws" {
  region  = "ap-southeast-2"
  alias   = "lb1"
}

provider "aws" {
  region  = "eu-west-2"
  alias   = "eu-west-2"
}
