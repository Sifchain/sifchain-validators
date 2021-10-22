// Sifchain terraform module
module sifchain {
    source                  = "github.com/sifchain/sifchain-deploy-validators/terraform/providers/aws"
    region                  = "us-west-2"
    cluster_name            = "sifchain-aws-{{.cluster}}"
    tags = {
        Terraform           = true
        Project             = "sifchain"
    }
}
