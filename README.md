🚀 EasyCRUD Deployment Using Jenkins CI/CD
(Pipeline Script from SCM + Terraform + Docker + AWS RDS)

This project demonstrates a complete automated CI/CD deployment of a Full Stack Application using:

✅ Jenkins (Pipeline Script from SCM)

✅ Terraform (Infrastructure as Code)

✅ AWS RDS (MariaDB – Free Tier)

✅ Docker (Backend + Frontend)

✅ Docker Hub (Image Registry)

🔗 GitHub Repository
https://github.com/orion-pax77/EasyCRUD-Docker-By-Jenkins.git
🏗️ Project Architecture
User → Frontend (Docker :80)
        ↓
Backend (Docker :8080)
        ↓
AWS RDS (MariaDB :3306)

Jenkins performs:

Infrastructure provisioning (Terraform)

Database & table creation

Backend configuration update

Docker image build

Container deployment

Docker Hub image push

📌 Prerequisites
🔹 AWS

AWS Account (Free Tier Supported)

IAM User with:

EC2

RDS

VPC

Security Group permissions

Access Key & Secret Key

🔹 Accounts Required

Docker Hub Account

GitHub Account

🟢 STEP 1: Launch EC2 (Ubuntu for Jenkins)

Go to:

AWS Console → EC2 → Launch Instance

Select:

AMI → Ubuntu Server 22.04 LTS

Instance Type → t3.medium

Storage → 20GB

Security Group:

22 (SSH)

8080 (Jenkins)

80 (Frontend)

8080 (Backend API)

3306 (Optional – only for public RDS testing)

Launch the instance.

🔹 Connect to EC2
ssh -i your-key.pem ubuntu@your-public-ip
🟢 STEP 2: Install Required Software
🔹 Update System
sudo apt update -y
☕ Install Java (Required for Jenkins)
sudo apt install openjdk-17-jdk -y

Verify:

java -version
🛠 Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install jenkins -y

Start Jenkins:

sudo systemctl start jenkins
sudo systemctl enable jenkins
🔹 Access Jenkins

Get password:

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

Open browser:

http://<EC2-PUBLIC-IP>:8080

Install suggested plugins.

🟢 Install Docker
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

Allow Jenkins to run Docker:

sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
🟢 Install Terraform
sudo apt install -y gnupg software-properties-common curl

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o \
  /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform -y

Verify:

terraform -version
🟢 Install MySQL Client
sudo apt install mysql-client -y
🟢 STEP 3: Add Credentials in Jenkins

Go to:

Manage Jenkins → Credentials → Global → Add Credentials
✅ 1. AWS Credentials

Kind → AWS Credentials

ID → aws-creds

Add Access Key & Secret Key

✅ 2. RDS Credentials

Kind → Username/Password

ID → rds-creds

Username → admin

Password → redhat123

✅ 3. Docker Hub Credentials

Kind → Username/Password

ID → dockerhub-cred

Add DockerHub username & password

Click Save.

🟢 STEP 4: Create Jenkins Pipeline (Pipeline Script from SCM)
🔹 1️⃣ Create New Job

Click New Item

Name → easycrud-deployment

Select → Pipeline

Click OK

🔹 2️⃣ Configure Pipeline

Scroll to Pipeline Section

Select:

Definition → Pipeline script from SCM

SCM → Git

Repository URL:
https://github.com/orion-pax77/EasyCRUD-Docker-By-Jenkins.git
Branch Specifier:
*/main
Script Path:
Jenkinsfile

Click Save.

🟢 STEP 5: Run Pipeline

Click:

Build Now
⚙️ What Jenkins Does Automatically
1️⃣ Clone Repository

Clones:

backend/

frontend/

terraform/

Jenkinsfile

2️⃣ Terraform Provisioning

Creates:

Security Group

DB Subnet Group

MariaDB RDS Instance

3️⃣ Fetch RDS Endpoint

Reads:

terraform output rds_endpoint
4️⃣ Create Database & Table

Creates:

student_db

admin user

students table

5️⃣ Update Backend Configuration

Updates:

backend/src/main/resources/application.properties

Sets:

RDS endpoint

DB port

Username

Password

MariaDB driver

6️⃣ Build Backend Docker Image
docker build -t backend-image .
7️⃣ Run Backend Container
docker run -d -p 8080:8080 backend-image
8️⃣ Update Frontend Environment

Sets:

BACKEND_URL=http://easycrud1-backend:8080
9️⃣ Build Frontend Docker Image
docker build -t frontend-image .
🔟 Run Frontend Container
docker run -d -p 80:80 frontend-image
1️⃣1️⃣ Push Images to Docker Hub

Pushes:

Backend image

Frontend image

🌐 Access Application

Frontend:

http://<EC2-PUBLIC-IP>

Backend:

http://<EC2-PUBLIC-IP>:8080
⏳ Expected Deployment Time

Terraform: 3–5 minutes

Docker build: 2–3 minutes

Total pipeline: 6–10 minutes

🛑 Destroy Infrastructure

Go to Jenkins workspace:

cd /var/lib/jenkins/workspace/easycrud-deployment/terraform
terraform destroy --auto-approve

Or create a destroy pipeline.

🏁 Final Outcome

After successful pipeline execution:

✅ AWS RDS created

✅ Database & table configured

✅ Backend running

✅ Frontend running

✅ Docker images pushed

✅ Fully automated CI/CD deployment

🎯 Skills Demonstrated

Infrastructure as Code (Terraform)

AWS Cloud Deployment

CI/CD using Jenkins (Pipeline Script from SCM)

Docker Containerization

Full Stack Application Deployment
