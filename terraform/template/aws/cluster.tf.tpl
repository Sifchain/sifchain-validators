// Sifchain terraform module
module sifchain {
    source                  = "github.com/sifchain/sifchain-deploy-public/terraform/providers/aws"
    region                  = "{{region}}"
    cluster_name            = "{{cluster_name}}"
    instance_type           = "{{instance_type}}"
    profile                 = "{{profile}}"
    tags = {
        Terraform           = true
        Project             = "sifchain"
    }
}
