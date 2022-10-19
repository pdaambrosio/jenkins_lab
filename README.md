# jenkins_lab

This is a lab for learning Jenkins.

## Prerequisites

* [Docker](https://www.docker.com/)
* [Git](https://git-scm.com/)
* [kubernetes](https://kubernetes.io/)

## Getting Started

### Docker

#### Build

```bash
docker build -t jenkins_lab .
```

#### Run

```bash
docker run -p 8080:8080 -p 50000:50000 jenkins_lab
```

### Kubernetes

#### Run

```bash
kubectl apply -f jenkins-sa.yaml
kubectl apply -f jenkins-deployment.yaml
```
