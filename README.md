# Luminating Atlantis

EKS cluster with nginx-ingress controller and Atlantis.

### How to run this project

Create ``terraform.tfvars``file and add variable values from file ``variables.tf``

### How to remove the installation

Simply running ``terraform destroy``might end up with null pointing objects in terraform state. To avoid this situation remove applications installed with Helm before. For example removing nginx-ingress controller and Atlantis run ``terraform destroy -target=helm_release.nginx_ingress -target=helm_release.atlantis``