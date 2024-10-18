
provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "stacks"
  region = "us-west-2"
}
