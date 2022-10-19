# jenkins_mapfre

Repository of Jenkins Mapfre

![](./map.png)

## How to use

### Install

```bash
git clone
cd jenkins_mapfre
terraform init
```

### Create

```bash
terraform apply
```

### Destroy

```bash
terraform destroy
```

## How to use with Docker

### Build

```bash
docker build -t jenkins_mapfre .
```

### Run

```bash
docker run -it --rm -v $(pwd):/app -w /app jenkins_mapfre
```

## How to use with Docker Compose

### Build

```bash
docker-compose build
```

### Run

```bash
docker-compose run --rm jenkins_mapfre
```

## How to use with Docker Compose and Makefile

### Build

```bash
make build
```

### Run

```bash
make run
```

## How to use with Docker Compose and Makefile and Docker Hub

### Build

```bash
make build
```

### Run

```bash
make run
```

### Push

```bash
make push
```

## How to use with Docker Compose and Makefile and Docker Hub and GitHub

### Build

```bash
make build
```

### Run

```bash
make run
```

### Push

```bash
make push
```

### Pull

```bash
make pull
```

### Deploy

```bash
make deploy
```

## License

MIT License
