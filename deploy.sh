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

  docker_endpoint=754256621582.dkr.ecr.eu-west-2.amazonaws.com
  docker_registry=${docker_endpoint}/${team_name}/${ecr_repo_name}

  usage="deploy -- deploy image from ECR to an environment
  Usage: ./deploy.sh image-tag environment
  Where:
    environment - one of development|staging|production
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

    # deploy image-tag to development
    ./deploy.sh pq-tracker-cloud-deploy-6bece953 development

    # deploy latest image of master to production
    ./deploy.sh pq-tracker-master-6bece953 production
    "

  # Ensure the script is called with two or three arguments
  if [ $# -lt 2 ] || [ $# -gt 3 ]
  then
    echo "$usage"
    return 0
  fi

  # Ensure that the first argument is a reasonable image name if not circleci (regexp diff in linux)
  if [[ "$3" == "circleci" ]]
  then
    image_tag=$1
  else
    if [[ "$1" =~ ^pf- ]]
    then
      p "\e[31mFatal error: Image tag not recognised: $1\e[0m"
      p "\e[31mPlease supply an image tag generated by the build script as the first argument\e[0m\n"
      echo "$usage"
      return 0
    else
      image_tag=$1
    fi
  fi

  # Ensure that the second argument is a valid stage
  case "$2" in
    development | staging | production)
      environment=$2
      ;;
    *)
      p "\e[31mFatal error: deployment environment not recognised: $2\e[0m"
      p "\e[31mEnvironment must be one of development | staging | production\e[0m\n"
      echo "$usage"
      return 0
      ;;
  esac

  # Ensure that the git-crypt secrets are unlocked ready for deployment
  if grep -rq "\x0GITCRYPT" k8s-deploy/$environment/secrets.yaml; then
    p "\e[31mFatal error: repository is locked with git-crypt\e[0m"
    p "\e[31mUnlock using 'git-crypt unlock'\e[0m\n"
    return 0
  fi

  # Confirm what's going to happen and ask for confirmation if not circle ci
  docker_image_tag=${docker_registry}:${image_tag}

  namespace=$component-${environment}
  p "--------------------------------------------------"
  p "Deploying PQ Tracker to kubernetes cluster: $context"
  p "Environment: \e[32m$environment\e[0m"
  p "Docker image: \e[32m$image_tag\e[0m"
  p "Target namespace: \e[32m$namespace\e[0m"
  p "--------------------------------------------------"

  if [[ "$3" != "circleci" ]]
  then
    if [[ $environment == "production" ]]
    then
      read -p "Do you wish to deploy this image to production? (Enter 'deploy' to continue): " confirmation_message
      if [[ $confirmation_message == "deploy" ]]
      then
        p "Deploying app to production..."
      else
        return 0
      fi
    else
      read -p "Do you wish to deploy this image to $environment? (Enter Y to continue): " confirmation_message
      if [[ $confirmation_message =~ ^[Yy]$ ]]
      then
        p "Deploying app to $environment..."
      else
        return 0
      fi
    fi
  fi

  # Apply config map updates
  kubectl apply \
    -f k8s-deploy/${environment}/config_map.yaml -n $namespace

  # Apply image specific config
  kubectl set image -f k8s-deploy/${environment}/deployment.yaml \
          parliamentary-questions-rails-app=${docker_image_tag} \
          --local --output yaml | kubectl apply -n $namespace -f -

  # Apply non-image specific config
  kubectl apply \
    -f k8s-deploy/${environment}/service.yaml \
    -f k8s-deploy/${environment}/ingress.yaml \
    -f k8s-deploy/${environment}/secrets.yaml \
    -n $namespace

  #nightly import to pull questions from the parliamentary API 
  if [ $environment == "staging" ] || [ $environment == "production" ]
  then
    kubectl set image -f k8s-deploy/${environment}/nightly_import_cronjob.yaml \
            nightly-import=${docker_image_tag} \
            --local --output yaml | kubectl apply -n $namespace -f -
  fi

  # #Trim and Sanitize database to limit the number of questions and obfuscate email address'  
  # if [ $environment == "staging" ]
  # then
  #   kubectl set image -f k8s-deploy/${environment}/trim_and_sanitize_db_cronjob.yaml \
  #           trim-and-anonymise-database=${docker_image_tag} \
  #           --local --output yaml | kubectl apply -n $namespace -f -
  # fi

  if [ $environment == "staging" ]
  then
    kubectl apply -f k8s-deploy/${environment}/smoke_test_cronjob.yaml -n $namespace
  fi

  # Schedule early bird email delivery 
  if [ $environment == "production" ]
  then
    kubectl set image -f k8s-deploy/${environment}/early_bird_dispatch_cronjob.yaml \
            early-bird-dispatch=${docker_image_tag} \
            --local --output yaml | kubectl apply -n $namespace -f -

    kubectl apply -f k8s-deploy/${environment}/cronjob-delete-old-ecr-images.yaml -n $namespace

  fi

  kubectl delete job rails-migrations -n $namespace --ignore-not-found=true

  kubectl set image -f k8s-deploy/${environment}/migration_job.yaml \
          parliamentary-questions-rails-app=${docker_image_tag} \
          --local --output yaml | kubectl apply -n $namespace -f -
}

_deploy $@
