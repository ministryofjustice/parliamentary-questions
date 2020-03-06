FROM ruby:2.5.5-alpine

RUN touch /etc/inittab

# Set correct environment variables.
ENV APP_HOME=/usr/src/app TINI_VERSION=v0.18.0 LD_LIBRARY_PATH=/opt/postgres/9.0.4/server/lib

# expect/add ping environment variables
ARG VERSION_NUMBER
ARG COMMIT_ID
ARG BUILD_DATE
ARG BUILD_TAG
ENV APP_VERSION_NUMBER=${VERSION_NUMBER}
ENV APP_COMMIT_ID=${COMMIT_ID}
ENV APP_BUILD_DATE=${BUILD_DATE}
ENV APP_BUILD_TAG=${BUILD_TAG}

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
      libc-dev \
      libxml2-dev \
      libxslt-dev \
      openssl-dev \
    && apk --no-cache add \
      bash \
      curl \
      file \
      libpq \
      linux-headers \
      nodejs \
      postgresql-dev \
      tzdata

ADD ./ /usr/src/app

COPY Gemfile* ./
RUN gem install bundler -v 2.0.2
RUN bundle install
COPY . .

RUN cd /usr/src/app  && \
    bundle config --global without build && \
    bundle  install -j 5 && \
    install -m 755 docker/run-pq.sh /run.sh && \
    install -m 755 docker/entrypoint.sh /entrypoint.sh && \
    echo 'export PATH=${APP_HOME}/bin:$PATH' >> /etc/bash.bashrc

RUN bundle exec rake assets:precompile RAILS_ENV=development PQ_REST_API_HOST=localhost PQ_REST_API_USERNAME=user PQ_REST_API_PASSWORD=pass DEVISE_SECRET=secret GOVUK_NOTIFY_API_KEY=key

RUN chmod +x /sbin/tini

# tidy up installation
RUN apk del build-dependencies

RUN addgroup -g 1000 -S appgroup \
    && adduser -u 1000 -S appuser -G appgroup

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup log tmp db

USER 1000

CMD ["/run-pq.sh"]
