#!/bin/bash

fatal() { echo -e "ERROR: $@" 1>&2; exit 1; }

# Check dependencies
aws --version || fatal 'The `aws` CLI tool is not available.';
terraform --version || fatal 'The `terraform` CLI tool is not available.';


action=${1:-"plan"};
shift;
workspace=$(terraform workspace show);
image=${1}
shift;
key=${1:-"key.pub"};
shift;

[ ! -f "${key}" ] && fatal "$key does not exist";
[ -z "$image" ] && [ "$action" != "destroy" ] && [ "$action" != "show" ] && fatal "No image specified";

echo "Current workspace: $workspace";
echo "Key file: $key";
echo "Image: $image";

terraform init -backend=true -get=true;
terraform get -update;

case $action in
    destroy)
        terraform destroy -force "$@";
        ;;
    show)
        terraform show
        ;;
    *)
        terraform $action -var "autoscale_image_id=$image" "$@";
        ;;
esac