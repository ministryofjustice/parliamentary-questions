#FROM ministryofjustice/ruby:2.2.3-webapp-onbuild
#FROM ministryofjustice/ruby:2-webapp-onbuild
#FROM registry.service.dsd.io/ministryofjustice/ruby:2.3.1
FROM ruby:2.3.1

RUN touch /etc/inittab

# Set correct environment variables.
ENV APP_HOME=/usr/src/app DEBIAN_FRONTEND=noninteractive TINI_VERSION=v0.9.0
# set WORKDIR
WORKDIR /usr/src/app
# Publish port 8080
EXPOSE 8080

# Add tini
#ENV TINI_VERSION v0.9.0   # Added above
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
#RUN chmod +x /tini # Added below
ENTRYPOINT ["/tini", "--", "/entrypoint.sh"]

# Optional packages nodejs/graphviz
# ---------------------------------
# First two lines also fix this error:
# E: The method driver /usr/lib/apt/methods/https could not be found.
# N: Is the package apt-transport-https installed?
RUN apt-get update && \
    apt-get install apt-transport-https && \
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    echo 'deb https://deb.nodesource.com/node jessie main' > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update
RUN apt-get install -y graphviz nodejs cron
# if you want "runit" instead of tiny, use the following line instead
#    apt-get install -y graphviz runit nodejs

### Get 'gosu'
RUN curl -o /usr/local/bin/gosu -fsSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture)" && \
    chmod 755 /usr/local/bin/gosu

ADD ./ /usr/src/app

RUN    cd /usr/src/app  && \
    bundle config --global without build && \
    bundle  install -j 5 && \
    install -m 755 docker-ng/rails/run-pq.sh /run.sh && \
    install -m 755 docker-ng/rails/entrypoint.sh /entrypoint.sh && \
    echo 'export PATH=${APP_HOME}/bin:$PATH' >> /etc/bash.bashrc
#    chown -R $APPUSER /rails

RUN   bundle exec rake assets:precompile RAILS_ENV=production PQ_REST_API_HOST=localhost PQ_REST_API_USERNAME=user PQ_REST_API_PASSWORD=pass DEVISE_SECRET=secret

RUN chmod +x /tini

CMD ["/run.sh"]

