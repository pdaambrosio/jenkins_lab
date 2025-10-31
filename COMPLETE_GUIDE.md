# Jenkins Lab - Complete Step-by-Step Guide

This comprehensive guide will walk you through setting up and using this Jenkins lab environment, which includes Jenkins with preconfigured plugins, worker nodes for Terraform and Ansible, SonarQube for code quality analysis, and sample Kubernetes deployments.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Overview](#project-overview)
3. [Quick Start (Docker)](#quick-start-docker)
4. [Kubernetes Deployment](#kubernetes-deployment)
5. [SonarQube Setup](#sonarqube-setup)
6. [Jenkins Configuration](#jenkins-configuration)
7. [Worker Nodes](#worker-nodes)
8. [Sample Projects](#sample-projects)
9. [Pipeline Usage](#pipeline-usage)
10. [Troubleshooting](#troubleshooting)
11. [Best Practices](#best-practices)

## 🔧 Prerequisites

Before starting, ensure you have:

- **Docker** (v20.10 or later) - [Install Docker](https://docs.docker.com/get-docker/)
- **Docker Compose** (v2.0 or later) - Usually included with Docker Desktop
- **Kubernetes** cluster (local or remote) - Options:
  - [Docker Desktop with Kubernetes](https://docs.docker.com/desktop/kubernetes/)
  - [Minikube](https://minikube.sigs.k8s.io/docs/start/)
  - [Kind (Kubernetes in Docker)](https://kind.sigs.k8s.io/)
  - Cloud providers (EKS, GKE, AKS)
- **kubectl** CLI tool - [Install kubectl](https://kubernetes.io/docs/tasks/tools/)
- **Git** - [Install Git](https://git-scm.com/downloads)
- At least **4GB RAM** and **10GB disk space** available

## 🏗️ Project Overview

This Jenkins lab provides:

### Core Components
- **Jenkins Master**: Pre-configured with 100+ plugins
- **Terraform Worker**: Jenkins agent with Terraform capabilities
- **Ansible Worker**: Jenkins agent with Ansible automation tools
- **SonarQube**: Code quality and security analysis
- **Sample Applications**: Including a voting app for testing deployments

### Key Features
- Blue Ocean modern UI
- Pre-configured security settings
- Integration with Git, Docker, Kubernetes
- Code quality gates with SonarQube
- Infrastructure as Code with Terraform
- Configuration management with Ansible

## 🚀 Quick Start (Docker)

### Step 1: Clone and Build

```bash
# Clone the repository
git clone <your-repo-url>
cd jenkins_lab

# Build the Jenkins image
docker build -t jenkins_lab .
```

### Step 2: Run Jenkins

```bash
# Run Jenkins container
docker run -d \
  --name jenkins_lab \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins_lab
```

### Step 3: Access Jenkins

1. Wait for Jenkins to start (check logs: `docker logs jenkins_lab`)
2. Open your browser and go to `http://localhost:8080`
3. Jenkins is pre-configured, so you should see the dashboard immediately
4. Default credentials are pre-set in the configuration

### Step 4: Verify Installation

- Check that all plugins are loaded
- Verify the Blue Ocean interface at `http://localhost:8080/blue`
- Confirm system configuration under "Manage Jenkins"

## ☸️ Kubernetes Deployment

### Step 1: Prepare Your Cluster

```bash
# Verify your cluster is running
kubectl cluster-info

# Check available nodes
kubectl get nodes
```

### Step 2: Create Namespace and Service Account

```bash
# Create the Jenkins namespace
kubectl apply -f jenkins-namespaces.yaml

# Create service account with proper permissions
kubectl apply -f jenkins-sa.yaml
```

### Step 3: Set up Storage and Secrets

```bash
# Create persistent volume for Jenkins data
kubectl apply -f jenkins-volume.yaml

# Apply any secrets (update with your actual secrets first)
kubectl apply -f jenkins-secret.yaml
```

### Step 4: Deploy Jenkins

```bash
# Deploy Jenkins to Kubernetes
kubectl apply -f jenkins-deployment.yaml

# Create service to expose Jenkins
kubectl apply -f jenkins-service.yaml

# Apply resource limits
kubectl apply -f jenkins-limit.yaml
```

### Step 5: Access Jenkins in Kubernetes

```bash
# Check deployment status
kubectl get pods -n jenkins
kubectl get services -n jenkins

# Port forward to access Jenkins locally
kubectl port-forward -n jenkins svc/jenkins-service 8080:8080

# Or get the external IP if using LoadBalancer service
kubectl get svc -n jenkins
```

## 🔍 SonarQube Setup

### Step 1: Start SonarQube

```bash
# Start SonarQube with PostgreSQL
docker-compose -f sonarqube-compose.yaml up -d

# Check if services are running
docker-compose -f sonarqube-compose.yaml ps
```

### Step 2: Configure SonarQube

1. Access SonarQube at `http://localhost:9000`
2. Login with default credentials: `admin/admin`
3. Change the default password when prompted
4. Create a new project for your applications
5. Generate authentication tokens for Jenkins integration

### Step 3: Integrate with Jenkins

1. Go to Jenkins → Manage Jenkins → Configure System
2. Find "SonarQube servers" section
3. Add server: `http://localhost:9000` (or your SonarQube URL)
4. Add authentication token from SonarQube

## ⚙️ Jenkins Configuration

### Understanding Pre-configured Settings

The Jenkins instance comes with:

#### Plugins (170+ installed)
- **Blue Ocean**: Modern UI and pipeline visualization
- **Git**: Source code management
- **Docker**: Container support
- **Kubernetes**: Cloud agents and deployment
- **Ansible**: Automation and configuration management
- **SonarQube**: Code quality integration
- **Pipeline**: Pipeline as Code support

#### Security Configuration
- CSRF protection enabled
- Security realm configured
- Authorization strategy set up
- API tokens configured

#### Global Tool Configuration
- Git tools configured
- Maven installation ready
- Docker available

### Customizing Configuration

To modify Jenkins configuration:

1. **Via UI**: Go to "Manage Jenkins" → "Configure System"
2. **Via Files**: Modify files in `config_jenkins/` directory and rebuild
3. **Via Groovy Scripts**: Use Jenkins Script Console

### Adding New Plugins

```bash
# Add plugin names to plugins.txt
echo "your-plugin-name:version" >> plugins.txt

# Rebuild the Docker image
docker build -t jenkins_lab .
```

## 🤖 Worker Nodes

### Terraform Worker

The Terraform worker provides infrastructure automation capabilities:

#### Features
- Terraform 1.2.9 pre-installed
- Alpine Linux base for minimal footprint
- Ready for Infrastructure as Code pipelines

#### Usage in Pipelines
```groovy
pipeline {
    agent {
        dockerfile {
            dir 'terraform_worker'
            label 'terraform'
        }
    }
    // Your terraform stages here
}
```

### Ansible Worker

The Ansible worker enables configuration management:

#### Features
- Ansible Core 2.13.4
- Python 3 with cryptography support
- SSH clients and utilities
- Ready for automation tasks

#### Usage in Pipelines
```groovy
pipeline {
    agent {
        dockerfile {
            dir 'ansible_worker'
            label 'ansible'
        }
    }
    // Your ansible playbook stages here
}
```

### Setting Up Kubernetes Agents

For dynamic Kubernetes-based agents:

```groovy
pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: terraform
    image: hashicorp/terraform:1.2.9
    command: ['sleep']
    args: ['infinity']
"""
        }
    }
    // Your pipeline stages
}
```

## 📦 Sample Projects

### Voting App

Located in `projects/votingapp/`, this sample application demonstrates:

- Kubernetes deployment configurations
- Service definitions
- Namespace management
- Multi-tier application architecture

#### Deploying the Voting App

```bash
# Navigate to the voting app directory
cd projects/votingapp

# Create namespace
kubectl apply -f namespaces/

# Deploy services
kubectl apply -f services/

# Deploy applications
kubectl apply -f deployments/

# Check deployment status
kubectl get all -n voting-app
```

## 🔄 Pipeline Usage

### Understanding the Sample Jenkinsfile

The provided `Jenkinsfile` demonstrates:

#### Parameters
- **action**: Terraform operations (show, plan, apply, destroy)
- **ENVIRONMENT**: Deployment environment (dev, hml, prod)
- **test1/test2**: Sample variables for testing

#### Stages
1. **Terraform Clone Repo**: Pulls infrastructure code
2. **Terraform Init**: Initializes Terraform
3. **Terraform Plan/Apply**: Executes infrastructure changes
4. **Cleanup**: Manages temporary files

### Creating Your Own Pipeline

1. **Create a new Pipeline job** in Jenkins
2. **Choose "Pipeline script from SCM"**
3. **Point to your repository** with a Jenkinsfile
4. **Configure parameters** as needed

### Example Pipeline for a Web Application

```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'your-registry.com'
        APP_NAME = 'my-web-app'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-org/your-repo.git'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarQubeScanner'
                    withSonarQubeEnv('SonarQube') {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_NUMBER} ."
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                sh "kubectl set image deployment/${APP_NAME} ${APP_NAME}=${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_NUMBER}"
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### Jenkins Won't Start
```bash
# Check container logs
docker logs jenkins_lab

# Common issues:
# - Insufficient memory (increase Docker memory allocation)
# - Port conflicts (change port mapping)
# - Permission issues (check volume permissions)
```

#### Kubernetes Deployment Issues
```bash
# Check pod status
kubectl describe pods -n jenkins

# Check logs
kubectl logs -n jenkins deployment/jenkins-deployment

# Common issues:
# - Image pull errors (check image name and registry access)
# - Resource constraints (check limits and cluster capacity)
# - RBAC issues (verify service account permissions)
```

#### SonarQube Connection Problems
```bash
# Check SonarQube container
docker-compose -f sonarqube-compose.yaml logs

# Test connectivity from Jenkins
curl -u admin:password http://localhost:9000/api/system/status
```

#### Plugin Issues
```bash
# View Jenkins logs for plugin errors
docker exec jenkins_lab tail -f /var/log/jenkins/jenkins.log

# Clear plugin cache and restart
docker exec jenkins_lab rm -rf /var/jenkins_home/plugins/*.jpi.pinned
docker restart jenkins_lab
```

### Performance Optimization

#### Jenkins Performance
- Increase JVM heap size: `-Xmx2g -Xms1g`
- Enable build caching
- Use pipeline libraries for common functions
- Implement proper build agent strategies

#### Docker Resource Management
```bash
# Limit container resources
docker run -d \
  --name jenkins_lab \
  --memory="2g" \
  --cpus="1.5" \
  -p 8080:8080 \
  jenkins_lab
```

## 📚 Best Practices

### Security Best Practices

1. **Change Default Credentials**
   - Update admin passwords immediately
   - Use strong, unique passwords
   - Enable two-factor authentication

2. **Network Security**
   - Use HTTPS in production
   - Implement proper firewall rules
   - Use VPN for remote access

3. **Access Control**
   - Implement role-based access control (RBAC)
   - Use least privilege principle
   - Regular audit user permissions

### Pipeline Best Practices

1. **Version Control**
   - Store Jenkinsfiles in source control
   - Use semantic versioning for releases
   - Tag important pipeline versions

2. **Error Handling**
   - Implement proper error handling in pipelines
   - Use try-catch blocks for critical sections
   - Set up proper notifications for failures

3. **Resource Management**
   - Use appropriate agents for different tasks
   - Clean up workspaces after builds
   - Implement build timeouts

### Maintenance Best Practices

1. **Regular Updates**
   - Keep Jenkins and plugins updated
   - Test updates in staging environment first
   - Backup configuration before updates

2. **Monitoring**
   - Monitor Jenkins performance metrics
   - Set up log aggregation
   - Implement health checks

3. **Backup Strategy**
   - Regular backup of Jenkins home
   - Test backup restoration procedures
   - Store backups securely off-site

### Development Workflow

1. **Feature Branches**
   - Use feature branches for development
   - Implement proper code review process
   - Merge only after successful pipeline execution

2. **Environment Promotion**
   - Deploy through multiple environments (dev → staging → prod)
   - Use environment-specific configurations
   - Implement automated testing at each stage

3. **Documentation**
   - Document pipeline configurations
   - Maintain runbooks for common operations
   - Keep architectural decisions recorded

## 🎯 Next Steps

### Expanding Your Lab

1. **Add More Workers**
   - Create specialized worker images (Python, Node.js, etc.)
   - Implement GPU-enabled workers for ML pipelines
   - Add Windows-based agents if needed

2. **Enhanced Monitoring**
   - Integrate with Prometheus and Grafana
   - Set up ELK stack for log analysis
   - Implement custom metrics collection

3. **Advanced Integrations**
   - Connect to cloud services (AWS, Azure, GCP)
   - Integrate with artifact repositories (Nexus, Artifactory)
   - Add notification integrations (Slack, Teams, email)

4. **Security Enhancements**
   - Implement Vault for secrets management
   - Add LDAP/Active Directory integration
   - Set up audit logging

### Learning Resources

- [Jenkins Official Documentation](https://www.jenkins.io/doc/)
- [Blue Ocean Documentation](https://www.jenkins.io/doc/book/blueocean/)
- [Pipeline Syntax Reference](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Kubernetes Plugin Documentation](https://plugins.jenkins.io/kubernetes/)

---

## 🤝 Contributing

This lab environment is designed for learning and experimentation. Feel free to:
- Add new worker types
- Enhance the sample applications
- Improve documentation
- Share your pipeline examples

Remember to test changes in a development environment before applying to production systems.

---

**Happy Learning with Jenkins! 🚀**