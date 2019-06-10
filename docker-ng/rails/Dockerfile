FROM ruby:2.5.5-alpine

RUN touch /etc/inittab

# Set correct environment variables.
ENV APP_HOME=/usr/src/app TINI_VERSION=v0.18.0

# set WORKDIR
RUN mkdir -p /usr/src/app && mkdir -p /usr/src/app/tmp
WORKDIR /usr/src/app

# Publish port 8080
EXPOSE 8080

# Add tini
#ENV TINI_VERSION v0.18.0 Added above
RUN apk add --no-cache tini

#RUN chmod +x /tini # Added below
ENTRYPOINT ["sbin/tini", "--", "/entrypoint.sh"]

# Optional packages nodejs
# ---------------------------------
# First two lines also fix this error:
# E: The method driver /usr/lib/apt/methods/https could not be found.
# N: Is the package apt-transport-https installed?
RUN apk update

RUN apk --no-cache add --virtual build-dependencies \
                      build-base \
                      libxml2-dev \
                      libxslt-dev \
                      postgresql-dev \
&& apk --no-cache add \
                  file \
                  nodejs \
                  linux-headers \
                  curl \
                  tzdata

ADD ./ /usr/src/app

RUN cd /usr/src/app  && \
    bundle config --global without build && \
    bundle  install -j 5 && \
    install -m 755 docker-ng/rails/run-pq.sh /run.sh && \
    install -m 755 docker-ng/rails/entrypoint.sh /entrypoint.sh && \
    echo 'export PATH=${APP_HOME}/bin:$PATH' >> /etc/bash.bashrc

RUN bundle exec rake assets:precompile RAILS_ENV=development PQ_REST_API_HOST=localhost PQ_REST_API_USERNAME=user PQ_REST_API_PASSWORD=pass DEVISE_SECRET=secret

RUN chmod +x /sbin/tini

RUN addgroup -g 1000 -S appgroup \
&& adduser -u 1000 -S appuser -G appgroup

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup log tmp db

USER 1000

CMD ["/run.sh"]
