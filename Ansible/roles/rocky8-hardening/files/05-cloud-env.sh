#------------------------------------------------------------------------
# Environment Variables Configuration for AWS instance-related variables
#-------------------------------------------------------------------------

# common variables
export VM_CLOUD_ID="ec2"

# variables from aws instance metadata
export VM_INSTANCE_ID="$(getMetadata /instance-id)"
## IP information
export VM_PUBLIC_IP="$(getMetadata /public-ipv4)"
export VM_PRIVATE_IP="$(getMetadata /local-ipv4)"
## VPC information
mac_addr=($(getMetadata /network/interfaces/macs))
eth0_mac="${mac_addr[0]::-1}"
export VM_VPC_ID="$(getMetadata /network/interfaces/macs/${eth0_mac}/vpc-id)"
export VM_SUBNET_ID="$(getMetadata /network/interfaces/macs/${eth0_mac}/subnet-id)"
export VM_ZONE="$(getMetadata /placement/availability-zone)"
export VM_REGION="${VM_ZONE:0:-1}"