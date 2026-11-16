# Jenkins Lab

A hands-on lab for running Jenkins as a containerized CI/CD controller, on Docker or on Kubernetes. It ships a pre-configured Jenkins image with plugins already installed, custom agent images for Terraform and Ansible, a sample declarative pipeline, a SonarQube stack for code-quality analysis, and a sample microservices application to deploy.

For a detailed walkthrough, see [COMPLETE_GUIDE.md](COMPLETE_GUIDE.md).

## Table of Contents

- [Architecture](#architecture)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Getting Started with Docker](#getting-started-with-docker)
- [Deploying on Kubernetes](#deploying-on-kubernetes)
- [Agent Images](#agent-images)
- [Sample Pipeline](#sample-pipeline)
- [SonarQube](#sonarqube)
- [Sample Application: Voting App](#sample-application-voting-app)
- [Managing Jenkins Configuration](#managing-jenkins-configuration)
- [Known Limitations](#known-limitations)

## Architecture

| Component | Description |
|-----------|-------------|
| Jenkins controller | Custom image based on `jenkins/jenkins:2.375.1-lts-jdk11`, with the plugins from `plugins.txt` and a restored `JENKINS_HOME` from `config_jenkins/`. The controller has 0 executors; builds run on agents. |
| Terraform agent | JNLP agent image with Terraform 1.2.9 installed. |
| Ansible agent | JNLP agent image with `ansible-core` 2.13.4, Python 3, SSH and rsync. |
| SonarQube | SonarQube 9.6.1 Community with PostgreSQL 14.5, run through Docker Compose. |
| Voting App | Five-service demo application (vote, result, worker, Redis, PostgreSQL) used as a Kubernetes deployment target. |

## Repository Structure

```
.
├── Dockerfile                  # Jenkins controller image
├── plugins.txt                 # Plugins installed at build time (jenkins-plugin-cli)
├── config_jenkins/             # JENKINS_HOME snapshot copied into the image
├── copy_config.sh              # Refreshes config_jenkins/ from a ThinBackup backup
├── Jenkinsfile                 # Sample Terraform + Ansible pipeline
├── terraform_worker/           # Terraform agent image
├── ansible_worker/             # Ansible agent image
├── jenkins-namespaces.yaml     # Kubernetes namespace
├── jenkins-sa.yaml             # Namespace, ServiceAccount, ClusterRole and binding
├── jenkins-deployment.yaml     # Deployment, Service and Ingress
├── jenkins-service.yaml        # Alternative LoadBalancer Service
├── jenkins-volume.yaml         # hostPath PersistentVolume
├── jenkins-limit.yaml          # LimitRange for the jenkins namespace
├── jenkins-secret.yaml         # Example Opaque Secret
├── sonarqube-compose.yaml      # SonarQube + PostgreSQL stack
├── projects/votingapp/         # Sample application manifests
└── COMPLETE_GUIDE.md           # Step-by-step guide
```

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- [Git](https://git-scm.com/)
- A Kubernetes cluster (for example minikube, kind or a managed cluster) and `kubectl`, for the Kubernetes deployment
- An Ingress controller in the cluster, if you use the Ingress in `jenkins-deployment.yaml`

## Getting Started with Docker

Build the controller image:

```bash
docker build -t jenkins_lab .
```

Run it, with a named volume for the ThinBackup directory:

```bash
docker run -d --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_backup:/srv/backup \
  jenkins_lab
```

Open http://localhost:8080. The setup wizard is skipped because the image includes an existing configuration, so sign in with an account from that configuration (`config_jenkins/users/`).

Port `8080` serves the web UI and port `50000` is used by inbound (JNLP) agents.

## Deploying on Kubernetes

Apply the manifests in this order:

```bash
kubectl apply -f jenkins-sa.yaml          # namespace, service account and RBAC
kubectl apply -f jenkins-limit.yaml       # default container resource limits
kubectl apply -f jenkins-volume.yaml      # optional: hostPath persistent volume
kubectl apply -f jenkins-secret.yaml      # optional: example secret
kubectl apply -f jenkins-deployment.yaml  # deployment, service and ingress
```

Check the rollout and reach the UI:

```bash
kubectl -n jenkins rollout status deployment/jenkins-deployment
kubectl -n jenkins port-forward svc/jenkins-service 8080:8080
```

The deployment uses the published image `pdaambrosio/jenkins-lts:1.2.0`. To use your own build, push it to a registry and update `image:` in `jenkins-deployment.yaml`.

The deployment includes liveness and readiness probes on `/login` and sets resources to requests of 1 CPU / 512Mi and limits of 2 CPU / 2Gi.

## Agent Images

Build and push the agent images so that the Kubernetes cloud in Jenkins can pull them:

```bash
docker build -t <registry>/jenkins-terraform-agent:1.2.9 terraform_worker/
docker build -t <registry>/jenkins-ansible-agent:2.13.4 ansible_worker/
docker push <registry>/jenkins-terraform-agent:1.2.9
docker push <registry>/jenkins-ansible-agent:2.13.4
```

The sample pipeline expects a pod template labeled `kubernetes` with containers named `terraform` and `ansible`. Configure it in **Manage Jenkins > Clouds > Kubernetes** (the Kubernetes plugin is pre-installed). For example:

```yaml
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins-sa
  containers:
    - name: terraform
      image: <registry>/jenkins-terraform-agent:1.2.9
      command: ["cat"]
      tty: true
    - name: ansible
      image: <registry>/jenkins-ansible-agent:2.13.4
      command: ["cat"]
      tty: true
```

## Sample Pipeline

The [Jenkinsfile](Jenkinsfile) is a declarative pipeline that runs Terraform and Ansible steps on Kubernetes agents.

**Parameters**

| Name | Values | Purpose |
|------|--------|---------|
| `action` | `show`, `plan`, `apply`, `preview-destroy`, `destroy` | Terraform action to run |
| `ENVIRONMENT` | `dev`, `hml`, `prod` | Target environment, passed to Terraform as `test_var1` |
| `test1`, `test2` | free text | Example string parameters |

**Stages**

1. Clone the Terraform repository, then run `terraform init` and `terraform validate`.
2. Run `terraform show` or `terraform plan` depending on `action`. The plan is saved to `tfplan` and `tfplan.txt`.
3. Clone the Ansible repository, check the Ansible version and run `ansible-playbook ping.yaml -i hosts`.

Only `show` and `plan` have stages for now. `apply`, `preview-destroy` and `destroy` can be selected but no stage runs for them yet.

**Required credentials**

| ID | Type | Used for |
|----|------|----------|
| `github_token` | Username with password or token | Cloning the Terraform and Ansible repositories |
| `terraform_cloud` | Secret text | Terraform Cloud API token (`TF_TOKEN_app_terraform_io`) |

## SonarQube

Start SonarQube and its PostgreSQL database:

```bash
docker compose -f sonarqube-compose.yaml up -d
```

Open http://localhost:9000 (default login `admin` / `admin`, which you must change on first sign-in). Create a token under **My Account > Security**, then register the server in Jenkins under **Manage Jenkins > System > SonarQube servers**. The SonarQube Scanner plugin is pre-installed.

SonarQube runs Elasticsearch, so on Linux hosts you may need to raise `vm.max_map_count`:

```bash
sudo sysctl -w vm.max_map_count=524288
```

## Sample Application: Voting App

`projects/votingapp/` contains the manifests for a distributed voting application, used as a deployment target for pipelines.

| Service | Image | Exposure |
|---------|-------|----------|
| vote | `kodekloud/examplevotingapp_vote:v1` | NodePort `31000` |
| result | `kodekloud/examplevotingapp_result:v1` | NodePort `31001` |
| worker | `kodekloud/examplevotingapp_worker:v1` | none |
| redis | `redis:alpine` | ClusterIP |
| postgres | `postgres:9.4` | ClusterIP |

Deploy it:

```bash
kubectl apply -f projects/votingapp/namespaces/
kubectl apply -f projects/votingapp/services/
kubectl apply -f projects/votingapp/deployments/
kubectl -n votingapp get pods,svc
```

## Managing Jenkins Configuration

The controller configuration lives in `config_jenkins/` and is copied into `/var/jenkins_home` when the image is built. It includes global settings, credentials, users, the `Brasil/environment_sul` folder and the installed plugins.

**Adding or upgrading plugins:** edit `plugins.txt` using the `plugin-id:version` format, then rebuild the image.

**Refreshing the configuration from a running instance:** the ThinBackup plugin writes backups to `/srv/backup`. When that path is mounted on the `jenkins_backup` Docker volume, `copy_config.sh` copies the latest full backup into `config_jenkins/`:

```bash
sudo ./copy_config.sh
```

The script matches backups whose names start with `FULL-2022`. Update that pattern before using it with newer backups.

## Known Limitations

This is a learning lab, not a production deployment. Before reusing it, note:

- `jenkins-deployment.yaml` sets `replicas: 2`. Jenkins controllers do not support active-active replication, so use a single replica.
- The deployment does not mount a persistent volume, so jobs and build history are lost when the pod is recreated. `jenkins-volume.yaml` defines a PersistentVolume but no PersistentVolumeClaim uses it.
- The selector in `jenkins-service.yaml` (`run: jenkins`) does not match the pod labels in the deployment (`app: jenkins`). Use the `jenkins-service` defined in `jenkins-deployment.yaml`, or change the selector.
- `jenkins-namespaces.yaml` and `jenkins-sa.yaml` both create the `jenkins` namespace. Applying both is safe but redundant.
- The base image (Jenkins 2.375.1 LTS) and the pinned tool and plugin versions are from 2022 and should be updated before any real use.

