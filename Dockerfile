FROM ruby:2.7.2-alpine
LABEL key="Ministry of Justice, Parlimentary Questions"
RUN set -ex

RUN addgroup --gid 1000 --system appgroup && \
    adduser --uid 1000 --system appuser --ingroup appgroup

# Set correct environment variables.
# ENV APP_HOME=/usr/src/app TINI_VERSION=v0.18.0 LD_LIBRARY_PATH=/opt/postgres/9.0.4/server/lib

RUN apk --no-cache add --virtual build-dependencies build-base libc-dev libxml2-dev libxslt-dev openssl-dev \
    && apk --no-cache add bash curl file libpq linux-headers nodejs postgresql-dev tzdata tini postgresql-client less

# set WORKDIR
WORKDIR /usr/src/app

RUN apk -U upgrade

# RUN mkdir -p /usr/src/app && mkdir -p /usr/src/app/tmp && mkdir -p /usr/src/app/log

COPY Gemfile* ./
RUN gem install bundler -v 2.2.15

# RUN bundle config --global without build && \
#     bundle  install -j 5

RUN bundle config set --global frozen 1 && \
    bundle config set without 'development test' && \
    bundle install -j 5

COPY . .

# Publish port 8080
# EXPOSE 8080

RUN mkdir log tmp
RUN chown -R appuser:appgroup /usr/src/app/
USER appuser
USER 1000

RUN RAILS_ENV=production PQ_REST_API_HOST=localhost PQ_REST_API_USERNAME=user PQ_REST_API_PASSWORD=pass DEVISE_SECRET=secret GOVUK_NOTIFY_API_KEY=key bundle exec rake assets:precompile

# ENTRYPOINT ["sbin/tini", "--", "/entrypoint.sh"]
# RUN chmod +x /sbin/tini

# RUN addgroup -g 1000 -S appgroup \
#     && adduser -u 1000 -S appuser -G appgroup

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup ./*
RUN chmod +x /usr/src/app/docker/*

# tidy up installation
RUN apk del build-dependencies

# USER 1000
# expect/add ping environment variables
ARG VERSION_NUMBER
ARG COMMIT_ID
ARG BUILD_DATE
ARG BUILD_TAG
ENV APPVERSION=${VERSION_NUMBER}
ENV APP_GIT_COMMIT=${COMMIT_ID}
ENV APP_BUILD_DATE=${BUILD_DATE}
ENV APP_BUILD_TAG=${BUILD_TAG}
