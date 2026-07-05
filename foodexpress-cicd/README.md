# FoodExpress CI/CD Pipeline — Setup Guide

Pipeline flow: **GitHub → Jenkins (build & push Docker image) → Terraform (provision EC2) → Jenkins (deploy container over SSH) → Public IP**

```
foodexpress-cicd/
├── app/               # Sample Node.js API + Dockerfile
├── terraform/         # Infra-as-code for the EC2 host
├── jenkins/           # Jenkinsfile (pipeline definition)
└── README.md
```

---

## 1. Prerequisites

| Tool | Where | Notes |
|---|---|---|
| AWS account | console.aws.amazon.com | With an IAM user that has EC2 + VPC permissions |
| Docker Hub account | hub.docker.com | To store built images |
| Jenkins server | EC2 / local VM | With plugins: Git, Docker Pipeline, SSH Agent, Terraform |
| Terraform CLI | Installed on Jenkins agent | v1.5+ |
| An existing EC2 Key Pair | AWS Console → EC2 → Key Pairs | Used for SSH deploy step |

---

## 2. Push the code to GitHub

```bash
git init
git add .
git commit -m "Initial FoodExpress CI/CD setup"
git remote add origin https://github.com/your-org/foodexpress-api.git
git push -u origin main
```

---

## 3. Prepare AWS

1. Create an IAM user (e.g. `jenkins-deployer`) with programmatic access and an `AmazonEC2FullAccess`-equivalent policy (scope this down in real production use).
2. Create/confirm an EC2 Key Pair named e.g. `foodexpress-keypair` — download the `.pem` file, you'll import it into Jenkins as an SSH credential.
3. Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars` and fill in your values (region, key_name, etc).

---

## 4. Set up Jenkins credentials

In **Jenkins → Manage Jenkins → Credentials**, add:

| Credential ID | Type | Value |
|---|---|---|
| `github-creds` | Username/password or token | GitHub PAT |
| `dockerhub-creds` | Username/password | Docker Hub login |
| `aws-access-key-id` | Secret text | IAM access key |
| `aws-secret-access-key` | Secret text | IAM secret key |
| `foodexpress-ec2-ssh` | SSH Username with private key | username `ec2-user`, paste the `.pem` contents |

---

## 5. Create the Jenkins pipeline job

1. New Item → Pipeline → name it `foodexpress-cicd`.
2. Under **Pipeline**, choose "Pipeline script from SCM" → Git → your repo URL → script path `jenkins/Jenkinsfile`.
3. (Optional) Add a **GitHub webhook** (Settings → Webhooks → payload URL `http://<jenkins-host>/github-webhook/`) so every push triggers a build automatically — this is what makes it "fully automated."

---

## 6. What each pipeline stage does

1. **Checkout** — pulls the latest code from GitHub.
2. **Build Docker Image** — builds the image from `app/Dockerfile`, tags it with the Jenkins build number and `latest`.
3. **Push Docker Image** — logs into Docker Hub and pushes both tags.
4. **Terraform Init & Apply** — provisions (or reuses, since Terraform is idempotent) the EC2 instance, security group, and installs Docker on it via `user_data`.
5. **Get EC2 Public IP** — reads the `public_ip` Terraform output into the pipeline.
6. **Deploy Container to EC2** — SSHes into the instance, pulls the new image, stops/removes any old container, and runs the new one.
7. **Verify Deployment** — curls the `/health` endpoint to confirm the app is live.

---

## 7. Run it

Push a commit to `main` (or click **Build Now** in Jenkins). Once the pipeline finishes, the console output prints something like:

```
App is live at: http://54.210.xx.xx:3000
```

Test it:
```bash
curl http://<EC2_PUBLIC_IP>:3000/health
curl http://<EC2_PUBLIC_IP>:3000/menu
```

Or hit it from **Postman**: `GET http://<EC2_PUBLIC_IP>:3000/menu`

---

## 8. Making it "scalable" (talking points for your write-up)

- Swap the single `aws_instance` for an **Auto Scaling Group** behind an **Application Load Balancer**, so Jenkins deploys new images by updating the ASG's launch template instead of SSH-ing into one box.
- Store Terraform state in an **S3 backend with DynamoDB locking** (commented block in `provider.tf`) so multiple Jenkins runs stay consistent.
- Replace the raw `docker run` deploy step with **ECS/Fargate** or **Kubernetes (EKS)** for zero-downtime rolling deploys.

---

## 9. Local test before pushing (optional)

```bash
cd app
docker build -t foodexpress-api .
docker run -p 3000:3000 foodexpress-api
curl http://localhost:3000/menu
```

---

## 10. Terraform commands (manual run, if not using Jenkins)

```bash
cd terraform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
terraform output public_ip
# to tear down:
terraform destroy -var-file=terraform.tfvars
```
