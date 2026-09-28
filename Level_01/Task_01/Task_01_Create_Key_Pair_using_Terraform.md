
# Task 01 : 
Create a Key Pair using Terraform

## Requirements :
Key Pair Name : `devops-kp`
Key Pair Type : `rsa`
Private Key File should be saved at : `/home/bob/devops-kp.pem`

## Infrastructure :
Cloud Service : AWS
Provider : AWS


## Solution :

### 🔷 Step 1 : Create Main Terraform Configuration
```hcl
# main.tf

# Generate RSA private key locally
resource "tls_private_key" "devops_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair using the public key
resource "aws_key_pair" "devops_kp" {
  key_name   = "devops-kp"
  public_key = tls_private_key.devops_key.public_key_openssh
}

# Save private key locally
resource "local_file" "private_key_pem" {
  content         = tls_private_key.devops_key.private_key_pem
  filename        = "/home/bob/devops-kp.pem"
  file_permission = "0400"
}
```
#### Configuration Breakdown:

* tls_private_key - Generates a 4096-bit RSA private key
* aws_key_pair - Creates AWS key pair with name "devops-kp"
* local_file - Saves private key with secure 0400 permissions


### 🔷 Step 2 : Terraform - Initialize, Format, Validate, Plan & Apply Configuration

* `terraform init` - Initialize the Terraform working directory
* `terraform fmt` - Format the Configuration
* `terraform validate` - Validate the Configuration
* `terraform plan` - Plan the Resource Creation
* `terraform apply -auto-approve` - Apply the Configuration

## Resources & their purpose : 

- **TLS Private Key Resource:** Generates RSA private key locally using Terraform
- **AWS Key Pair Resource:** Creates the key pair in AWS using the generated public key
- **Local File Resource:** Saves the private key to the specified local path with proper permissions

## Verify Resource Provisioned :

### Check-Point 1 : Key Pair creation in AWS

#### List Resources provisioned :
```bash
terraform state list
```
#### Expected Output :
```bash
aws_key_pair.devops_kp
local_file.private_key_pem
tls_private_key.devops_key
```

### Check-Point 2 : Check if Key Pair exists

#### Show key pair details from Terraform state :
```bash
terraform show | grep -A 5 "aws_key_pair"
```
#### Expected Output :
```bash
# aws_key_pair.devops_kp:
resource "aws_key_pair" "devops_kp" {
    arn             = < ARN of AWS Resource >
    fingerprint     = < Finger-Print of Resource >
    id              = "devops-kp"
    key_name        = "devops-kp"
    key_name_prefix = null
```

### Check-Point 3 : Private Key File

#### Check Private Key File is created with required permissions :
```bash
ls -l /home/bob/devops-kp.pem
```
#### Expected Output :
```bash
-rw------- 1 bob bob 3247 [date] /home/bob/devops-kp.pem
```

### Check-Point 4 : Check Key File Format

#### Check the Private Key File is in a valid format :
```bash
head -n 1 /home/bob/devops-kp.pem
```
#### Expected Output :
```bash
-----BEGIN RSA PRIVATE KEY-----
```

### Check-Point 5 : Check Private Key Integrity

#### Check the Private Key Format and Structure :
```bash
openssl rsa -in /home/bob/devops-kp.pem -check -noout
```
#### Expected Output :
```bash
RSA key ok
```

## Common Issues :
**Issue 1 : Permission denied when creating private key file**
- **Symptoms :** Error creating `/home/bob/devops-kp.pem`
- **Solution :** Ensure the directory exists and has proper write permissions
```bash
# Ensure directory exists
mkdir -p /home/bob
# Check permissions
ls -ld /home/bob
```

**Issue 2 : AWS credentials not configured**
- **Symptoms :** Error: "No valid credential sources found"
- **Solution :** Configure AWS credentials
```bash
# Configure AWS CLI
aws configure
# Or set environment variables
export AWS_ACCESS_KEY_ID="my-access-key"
export AWS_SECRET_ACCESS_KEY="my-secret-key"
```

**Issue 3 : Key pair already exists in AWS**
- **Symptoms :** Error: "InvalidKeyPair.Duplicate"
- **Solution :** Import existing key pair or use different name
```bash
# Import existing key pair (if you have the public key)
terraform import aws_key_pair.devops_kp devops-kp
```

## Best Practices :
- **🔐 Security :** Private key stored with restrictive 0400 permissions
- **📊 Resource Management :** Using resource dependencies for correct creation order
- **🏷️ Naming Conventions :** Clear, descriptive resource names matching requirements
- **🔄 State Management :** All resources managed in Terraform state for consistency

## Production Considerations :
- **Scalability :** Key pairs can be referenced across multiple EC2 instances
- **Security :** Consider using AWS Systems Manager Parameter Store for sensitive data
- **Backup/Recovery :** Store private keys securely in encrypted storage
- **Access Control :** Implement IAM policies to control key pair management

