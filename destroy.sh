#!/bin/bash

###############################################################################
#
# Tear down terraform-managed resources.
#
###############################################################################

# Bash safeties: exit on error, no unset variables, pipelines can't hide errors
set -o errexit
set -o nounset
set -o pipefail

K8S_NAMESPACE="$(cd terraform && terraform output --raw kubernetes_namespace)"

# Perform the destroy
(cd "${PWD}/terraform"; terraform destroy -input=false -auto-approve)