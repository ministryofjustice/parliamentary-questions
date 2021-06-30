#!/bin/sh

# exit when any command fails
set -e

p() {
  printf "\e[33m$1\e[0m\n"
}

function _deploy() {

  # Define variables for use in the script
  team_name=pq-team
  ecr_repo_name=parliamentary-questions
  component=parliamentary-questions

  context='live-1'
  environment="staging"
  docker_endpoint=754256621582.dkr.ecr.eu-west-2.amazonaws.com
  docker_registry=${docker_endpoint}/${team_name}/${ecr_repo_name}

  usage="deploy -- deploy image from ECR to an environment
  Usage: ./deploy.sh image-tag
  Where:
    image-tag   - any valid ECR image tag for app generated by build script
  Prerequisites:
    Build an image to deploy using build.sh in a checked out
    copy of the head of the branch you want to deploy. Supply the
    resulting image tag to this deploy script.
  Example:
    # build the app to get an image tag
    ./build.sh
    ...many lines of output...
    Image created with tag: pq-tracker-cloud-deploy-6bece953

    # deploy image-tag to staging
    ./deploy.sh pq-tracker-cloud-ciwciwii-6bece953 staging
    "

  # Ensure the script is called with two or three arguments
  if [ $# -lt 1 ]
  then
    echo "$usage"
    return 0
  fi
  image_tag=$1
  # Confirm what's going to happen and ask for confirmation if not circle ci
  docker_image_tag=${docker_registry}:${image_tag}

  namespace=$component-${environment}
  p "--------------------------------------------------"
  p "Deploying PQ Tracker to kubernetes cluster: $context"
  p "Environment: \e[32m$environment\e[0m"
  p "Docker image: \e[32m$image_tag\e[0m"
  p "Docker image tag: \e[32m$docker_image_tag\e[0m"
  p "Target namespace: \e[32m$namespace\e[0m"
  p "--------------------------------------------------"

  if [[ "$2" != "circleci" ]]
  then
    read -p "Do you wish to deploy this image to $environment? (Enter Y to continue): " confirmation_message
    if [[ $confirmation_message =~ ^[Yy]$ ]]
    then
    p "Deploying app to $environment..."
    else
    return 0
    fi
  fi

  if [ $environment == "staging" ]
  then
    kubectl delete job early-bird-dispatch -n $namespace --ignore-not-found=true
    
    kubectl set image -f ./early_bird_dispatch_cronjob.yaml \
            early-bird-dispatch=${docker_image_tag} \
            --local --output yaml | kubectl apply -n $namespace -f -

  fi

}

_deploy $@