# Default
provider "aws" {
  version = "2.33.0"
  region  = "us-east-1"
}

provider "aws" {
  version = "2.33.0"
  region  = "ap-southeast-2"
  alias   = "ap-southeast-2"
}

provider "aws" {
  version = "2.33.0"
  region  = "ap-southeast-2"
  alias   = "lb1"
}

provider "aws" {
  version = "2.33.0"
  region  = "eu-west-2"
  alias   = "eu-west-2"
}
