d-restart(){
  docker restart $1
}

d-stop(){
  docker stop $1
}

d-start(){
  docker start $1
}

d-logs(){
  docker logs $1 -f --tail 100
}

d-exec(){
  docker exec -it $1 /bin/bash
}

d-rm(){
  docker rm $1
}

d-rmi(){
  docker rmi $1
}

d-ps(){
  docker ps
}

d-psa(){
  docker ps -a
}

# Completion function for Docker container names
_docker_containers() {
  local containers
  containers=($(docker ps -a --format '{{.Names}}'))
  _describe 'containers' containers
}

# Completion function for Docker image names
_docker_images() {
  local images
  images=($(docker images --format '{{.Repository}}:{{.Tag}}'))
  _describe 'images' images
}

# Bind the completion function to the custom Docker functions
compdef _docker_containers d-restart
compdef _docker_containers d-stop
compdef _docker_containers d-start
compdef _docker_containers d-logs
compdef _docker_containers d-exec
compdef _docker_containers d-rm
compdef _docker_images d-rmi
compdef _docker_containers d-ps
compdef _docker_containers d-psa