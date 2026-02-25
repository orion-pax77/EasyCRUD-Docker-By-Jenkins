# 🚀 Jenkins + Terraform + Docker + RDS Deployment Guide

## (Production CI/CD Setup – Pipeline Script from SCM)

This project automates deployment of a **Full Stack Application (Backend + Frontend)** using:

* ✅ **AWS RDS (MariaDB)**
* ✅ **Terraform (Infrastructure as Code)**
* ✅ **Docker (Containerization)**
* ✅ **Docker Hub (Image Registry)**
* ✅ **Jenkins CI/CD (Pipeline Script from SCM)**

All infrastructure and application deployment is automated using a **Jenkins pipeline stored in GitHub**.

---

# 📌 Prerequisites

## 🔹 AWS Requirements

* AWS Account (Free Tier Supported)
* IAM User with permissions for:

  * EC2
  * RDS
  * VPC
  * Security Groups
* Access Key & Secret Key

## 🔹 Required Accounts

* Docker Hub Account
* GitHub Repository

```
https://github.com/orion-pax77/EasyCRUD-Docker-By-Jenkins.git
```

---

# 🟢 STEP 1: Launch EC2 Instance (Ubuntu for Jenkins)

Go to:

```
AWS Console → EC2 → Launch Instance
```

### Select:

* **AMI** → Ubuntu Server 22.04 LTS
* **Instance Type** → c7i-flex.large
* **Storage** → 20 GB

### Security Group Ports:

| Port | Purpose              |
| ---- | -------------------- |
| 22   | SSH                  |
| 8080 | Jenkins              |
| 80   | Frontend             |
| 8080 | Backend              |
| 3306 | (Only if RDS Public) |

Launch the instance.

---

## 🔹 Connect to EC2

```bash
ssh -i your-key.pem ubuntu@your-public-ip
```

---

# 🟢 STEP 2: Install Required Software

---

## 🔹 Update System

```bash
sudo apt update -y
```

---

## ☕ Install Java (Required for Jenkins)

```bash
sudo apt install openjdk-17-jdk -y
```

Verify:

```bash
java -version
```

---

## 🛠 Install Jenkins

```bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install jenkins -y
```

Start Jenkins:

```bash
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

---
Perfect 👍 Below is your updated documentation section with a **new step added right after Jenkins installation** to change Jenkins port from **8080 → 8081** in a clean GitHub-ready format.

You can directly replace that section in your README.

---

## 🛠 Install Jenkins

```bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install jenkins -y
```

Start Jenkins:

```bash
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

---

# 🟢 Change Jenkins Default Port (8080 → 8081)

By default, Jenkins runs on **port 8080**.
Since port 8080 will be used by the Backend container, we will change Jenkins to **8081**.

---

## 🔹 Edit Jenkins Configuration

Open Jenkins config file:

```bash
sudo nano /lib/systemd/system/jenkins.service
```

Find this line:

```bash
Environment="JENKINS_PORT=8080"
```

Change it to:

```bash
Environment="JENKINS_PORT=8081"
```

Save and exit.

---

## 🔹 Restart Jenkins

```bash
sudo systemctl daemon-reload
sudo systemctl stop jenkins
sudo systemctl start jenkins
```

---

## 🔹 Verify Jenkins is Running on 8081

```bash
sudo systemctl status jenkins
```

## 🔹 Access Jenkins

Get admin password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Open browser:

```
http://<EC2-PUBLIC-IP>:8081
```

Install **Suggested Plugins**.

---

## 🟢 Install Docker

```bash
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
```

Allow Jenkins to use Docker:

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

---

## 🟢 Install Terraform

```bash
sudo apt install -y gnupg software-properties-common curl

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o \
  /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform -y
```

Verify:

```bash
terraform -version
```

---

## 🟢 Install MySQL Client

```bash
sudo apt install mysql-client -y
```

---

## 🟢 Install AWS CLI

```bash
sudo snap install aws-cli --classic
```

Verify installation:

```bash
aws --version
```

---

## 🟢 Configure AWS CLI

Run:

```bash
aws configure
```

Enter:

* AWS Access Key
* AWS Secret Access Key
* Default Region → `us-east-1`
* Default Output → `json`

> ⚠️ Note:
> In production environments, AWS credentials should be stored inside **Jenkins Credentials** instead of using `aws configure`. This step is optional if Jenkins credentials are properly configured.

---

# 🟢 STEP 3: Add Credentials in Jenkins

Go to:

```
Manage Jenkins → Credentials → Global → Add Credentials
```

---

## ✅ 1️⃣ AWS Credentials

* Kind → AWS Credentials
* ID → `aws-creds`
* Add Access Key & Secret Key

---

## ✅ 2️⃣ RDS Credentials

* Kind → Username/Password
* ID → `rds-creds`
* Username → `admin`
* Password → `redhat123`

---

## ✅ 3️⃣ Docker Hub Credentials

* Kind → Username/Password
* ID → `dockerhub-cred`
* Add DockerHub username & password

Click **Save**.

---


# 🟢 STEP 4: Create Jenkins Pipeline (Pipeline Script from SCM)

---

## 🔹 1️⃣ Create New Job

* Click **New Item**
* Name → `easycrud-deployment`
* Select → **Pipeline**
* Click **OK**

---

## 🔹 2️⃣ Configure Pipeline

Scroll to **Pipeline Section**

Select:

```
Definition → Pipeline script from SCM
SCM → Git
```

### Repository URL:

```
https://github.com/orion-pax77/EasyCRUD-Docker-By-Jenkins.git
```

### Branch:

```
*/main
```

### Script Path:

```
Jenkinsfile
```

Click **Save**.

---

# 🟢 STEP 5: Run the Pipeline

Click:

```
Build Now
```

---

# ⚙️ What Happens Automatically

---

## 1️⃣ Jenkins Clones Repository

Clones:

* `backend/`
* `frontend/`
* `terraform/`
* `Jenkinsfile`

---

## 2️⃣ Terraform Creates AWS Infrastructure

* Default VPC
* Security Group
* DB Subnet Group
* MariaDB RDS Instance

---

## 3️⃣ Jenkins Fetches RDS Endpoint

```bash
terraform output rds_endpoint
```

---

## 4️⃣ Jenkins Creates Database & Table

Creates:

* `student_db`
* `admin` user
* `students` table

---

## 5️⃣ Jenkins Updates Backend Configuration

Updates:

```
backend/src/main/resources/application.properties
```

Sets:

* RDS endpoint
* DB port
* Username
* Password
* MariaDB driver

---

## 6️⃣ Jenkins Builds Backend Docker Image

```bash
docker build -t backend-image .
```

---

## 7️⃣ Jenkins Runs Backend Container

```bash
docker run -d -p 8080:8080 backend-image
```

---

## 8️⃣ Jenkins Updates Frontend Environment

Sets:

```
VITE_API_URL=http://easycrud1-backend:8080
```

---

## 9️⃣ Jenkins Builds Frontend Docker Image

```bash
docker build -t frontend-image .
```

---

## 🔟 Jenkins Runs Frontend Container

```bash
docker run -d -p 80:80 frontend-image
```

---

## 1️⃣1️⃣ Jenkins Pushes Images to Docker Hub

Pushes:

* Backend image
* Frontend image

---

# ⏳ Expected Deployment Time

| Task                   | Time         |
| ---------------------- | ------------ |
| Terraform Provisioning | 3–5 minutes  |
| Docker Build           | 2–3 minutes  |
| Full Pipeline          | 6–10 minutes |

---

# 🎯 Final Result

After successful pipeline execution:

* ✅ AWS RDS Created
* ✅ Database & Table Created
* ✅ Backend Running (Port 8080)
* ✅ Frontend Running (Port 80)
* ✅ Docker Images Pushed
* ✅ Fully Automated CI/CD Deployment

---

# 🌐 Access Application

### Frontend

```
http://<EC2-PUBLIC-IP>
```

### Backend

```
http://<EC2-PUBLIC-IP>:8080
```

---

# 🛑 Destroy Infrastructure

Navigate to Jenkins workspace:

```bash
cd /var/lib/jenkins/workspace/easycrud-deployment/terraform
terraform destroy --auto-approve
```

Or create a separate destroy pipeline.

---

# 🏁 Conclusion

This project demonstrates:

* ✅ Infrastructure as Code (Terraform)
* ✅ Automated Cloud Deployment
* ✅ CI/CD using Jenkins (Pipeline Script from SCM)
* ✅ Docker Containerization
* ✅ Production-ready Deployment Architecture

---


