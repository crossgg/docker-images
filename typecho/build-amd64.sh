#/bin/sh

docker image rm -f docker.io/80x86/typecho:v1.3.0-amd64
docker build -f ./docker/Dockerfile -t  docker.io/80x86/typecho:v1.3.0-amd64 .
docker push docker.io/80x86/typecho:v1.3.0-amd64
