# ci-utils
A container to be used in CircleCI. Includes common utilities, such as  yq, and docker-compose. 

# Building. 
* Pushes to master build :latest 
* Tags will build a :$CIRCLE_TAG


# Utilities

## yq
- cli utility to update yaml files within CI. 
- update the ENV=YQ_VERSION in the dockerfile to update


## docker 
- docker comes from apt-get, and is installed on build

## docker-compose 
- docker-compose comes from the official github releases
- update the ENV=COMPOSE_VERSION to update
