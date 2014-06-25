
if [ -n "$1" ]; then 
  export VERSION=`echo "$1" | sed -e "s/.*release\///g"`
else
  export VERSION='latest'
fi

DATE=`date`

cat <<EOT >MANIFEST
Version: $VERSION
Date: $DATE

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

# Notify hipchat in Jenkins

export DOCKERTAG="${DOCKER_PREFIX}assets"
echo "Building Assets Container ($VERSION)"
./docker/assets/make.sh $VERSION

export DOCKERTAG="${DOCKER_PREFIX}rails"
echo "Building Rails Container ($VERSION)"
./docker/rails/make.sh $VERSION

