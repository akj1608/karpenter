#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if kubectl is installed
if ! command_exists kubectl; then
    echo "Error: kubectl is not installed. Please install kubectl and try again."
    exit 1
fi

# Check if kubectl can connect to the cluster
if ! kubectl get nodes &>/dev/null; then
    echo "Error: Unable to connect to the EKS cluster. Please ensure your kubeconfig is properly configured."
    exit 1
fi

# Create a directory to store the Karpenter configuration
output_dir="karpenter_config_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$output_dir"

echo "Scraping Karpenter configuration..."

# Fetch Karpenter NodePools
echo "Fetching NodePools..."
kubectl get nodepools.karpenter.sh -o yaml > "$output_dir/nodepools.yaml"

# Fetch Karpenter EC2NodeClasses
echo "Fetching EC2NodeClasses..."
kubectl get ec2nodeclasses.karpenter.k8s.aws -o yaml > "$output_dir/ec2nodeclasses.yaml"

# Fetch Karpenter Provisioners (if using an older version of Karpenter)
echo "Fetching Provisioners (if any)..."
kubectl get provisioners.karpenter.sh -o yaml > "$output_dir/provisioners.yaml" 2>/dev/null

# Fetch Karpenter ConfigMap
echo "Fetching Karpenter ConfigMap..."
kubectl get configmap -n karpenter karpenter-global-settings -o yaml > "$output_dir/karpenter-configmap.yaml" 2>/dev/null

# Fetch Karpenter Deployment
echo "Fetching Karpenter Deployment..."
kubectl get deployment -n karpenter karpenter -o yaml > "$output_dir/karpenter-deployment.yaml" 2>/dev/null

# Fetch Karpenter ServiceAccount
echo "Fetching Karpenter ServiceAccount..."
kubectl get serviceaccount -n karpenter karpenter -o yaml > "$output_dir/karpenter-serviceaccount.yaml" 2>/dev/null

echo "Karpenter configuration has been scraped and saved in the '$output_dir' directory."
