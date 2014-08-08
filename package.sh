#!/bin/bash

CONTAINERS=(assets rails)

DEFAULT_DOCKERREPO="docker.local:5000"
DEFAULT_DOCKERTAG="assets"

DOCKERFILE="docker/assets/Dockerfile"
DOCKERREPO="${DOCKERREPO:-$DEFAULT_DOCKERREPO}"
DOCKERTAG="${DOCKERTAG:-$DEFAULT_DOCKERTAG}"


tag()
{
	if [ -n "$2" ]; then
  		TAG="${DOCKERREPO}/$1:$2"
	else
		TAG="${DOCKERREPO}/$1"
	fi
        echo $TAG
}

output()
{
	echo "$(tput setaf 1)$1$(tput sgr 0)"
}

docker_build() 
{
	TAG=$(tag $1 $2)
	[ ! -d "docker" ] && output "Please run from git root" && exit 1

	cp ${DOCKERFILE} .
        output "+ docker build -t ${TAG} --force-rm=true ."
	docker build -t ${TAG} --force-rm=true .
}

docker_push()
{
	TAG=$(tag $1)
	# Skip push if build generates an error
	[ "$?" -ne 0 ] && DOCKER_NOPUSH=true

	output "+ docker push ${TAG}"
	docker push ${TAG}
}

docker_rmi()
{
	TAG=$(tag $1)
	if [ -z "$DOCKER_NORMI" ]; then
  		output "+ docker rmi ${TAG}"
  		docker rmi ${TAG}
	fi
}


###
###
###
if [ -n "$1" ]; then 
  export APPVERSION=`echo "$1" | sed -e "s/.*release\///g"`
else
  export APPVERSION='latest'
fi

DATE=`date`

cat <<EOT >MANIFEST
Version:  $APPVERSION
Date:     $DATE
BuildTag: $BUILD_TAG
Commit:   $GIT_COMMIT

EOT


# Generate a self contained bundle
#cd build
bundle --quiet \
       --path vendor/bundle \
       --deployment \
       --standalone \
       --binstubs \
       --without build


bundle exec rake assets:precompile RAILS_ENV=production

# Build containers
for i in  ${CONTAINERS[@]}; do
  docker_build "${DOCKER_PREFIX}${i}" $APPVERSION
  RETCODE=$?
  if [ "$RETCODE" -ne 0 ]; then
     BUILD_FAILED=$RETCODE
     DOCKER_NOPUSH=true
     output "Failed with code $BUILD_FAILED - skipping further builds and disabling push"
     break
  fi
done


# Push containers only if all builds were successful and DOCKER_NOPUSH isn't specified
if [ -z "$DOCKER_NOPUSH" ]; then
	for i in  ${CONTAINERS[@]}; do
		docker_push "${DOCKER_PREFIX}${i}"
	done
else
	output "Not pushing images"
fi

if [ -z "$DOCKER_NORMI" ]; then
	for i in  ${CONTAINERS[@]}; do
		docker_rmi "${DOCKER_PREFIX}${i}"
	done
else
	output "Not removing images"
fi


