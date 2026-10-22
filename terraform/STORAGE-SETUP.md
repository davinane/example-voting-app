# EKS Persistent Storage Setup

This project uses Amazon EBS CSI to provide persistent PostgreSQL storage.

## Components

- EKS cluster, OIDC provider, and EBS CSI add-on: Terraform
- EBS CSI IAM role: eksctl / CloudFormation
- gp3 StorageClass: Kubernetes YAML
- PostgreSQL PVC: Helm chart

## Fresh Cluster Setup

1. Provision the EKS cluster, worker nodes, and OIDC provider first.
   A fresh deployment requires staged Terraform applies because the
   EBS CSI add-on depends on an IAM role created separately by eksctl.
   Do not run the complete Terraform configuration before that role exists.

   From the terraform directory, initialize Terraform and provision
   the initial infrastructure using a targeted apply:

       terraform init
       terraform apply -target=aws_iam_openid_connect_provider.eks -target=aws_eks_node_group.capstone

   Targeted applies are only used here to bootstrap dependencies.
   Review the plan before approving.

2. Configure kubectl:

   aws eks update-kubeconfig \
     --region ca-central-1 \
     --name ts-academy-capstone-eks \
     --profile terraform-capstone

3. Create the EBS CSI IAM role using eksctl:

   AWS_PROFILE=terraform-capstone eksctl create iamserviceaccount \
     --cluster ts-academy-capstone-eks \
     --region ca-central-1 \
     --namespace kube-system \
     --name ebs-csi-controller-sa \
     --role-name ts-academy-ebs-csi-role \
     --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
     --role-only \
     --approve

4. After the IAM role exists, return to the terraform directory
   and complete the infrastructure deployment:

       terraform plan
       terraform apply

   Confirm that the EBS CSI add-on is ACTIVE before proceeding.
   The add-on must use the IAM role created in Step 3.

5. Apply the StorageClass:

   AWS_PROFILE=terraform-capstone kubectl apply \
     -f gp3-storageclass.yaml

6. Verify storage:

   AWS_PROFILE=terraform-capstone kubectl get storageclass gp3

   AWS_PROFILE=terraform-capstone kubectl get pvc -n voting-app

## Important Notes

The IAM role is owned by an eksctl CloudFormation stack.
Do not independently manage the same IAM role with Terraform.

The OIDC provider must exist before creating the IAM role.
The EBS CSI add-on must be active before PostgreSQL can
provision its EBS volume.

This setup currently requires Terraform, eksctl, and kubectl.
It is not a Terraform-only deployment.

## Rebuild Considerations

The current Terraform configuration references the existing EBS CSI
IAM role and preserves the current OIDC thumbprint.

A fresh cluster requires the OIDC provider, IAM role, and EBS CSI
add-on to be configured in the correct order. The current setup
is not yet a fully automated fresh-cluster deployment.

## Cleanup

Before destroying the infrastructure, uninstall the Helm release
and remove its persistent storage after confirming that no data
needs to be retained.

Remove the Terraform-managed resources and the separate
CloudFormation stack in a dependency-safe order.

The AWS budget alert is not a spending cap.
