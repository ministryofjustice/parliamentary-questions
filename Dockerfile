FROM ruby:3.2.2-alpine
LABEL key="Ministry of Justice, Parlimentary Questions"
RUN set -ex

RUN addgroup --gid 1000 --system appgroup && \
    adduser --uid 1000 --system appuser --ingroup appgroup

RUN apk --no-cache add --virtual build-dependencies build-base libc-dev libxml2-dev libxslt-dev openssl-dev \
    && apk --no-cache add bash curl file libpq linux-headers nodejs postgresql-dev tzdata tini postgresql-client less

RUN apk -U upgrade

# set WORKDIR
WORKDIR /usr/src/app

COPY Gemfile* ./
RUN gem install bundler -v 2.4.13

RUN bundle config set --global frozen 1 && \
    bundle config set without 'development' && \
    bundle install -j 5

COPY . .

RUN mkdir log tmp
RUN chown -R appuser:appgroup /usr/src/app/
USER appuser
USER 1000

RUN RAILS_ENV=production PQ_REST_API_HOST=localhost PQ_REST_API_USERNAME=user PQ_REST_API_PASSWORD=pass DEVISE_SECRET=secret GOVUK_NOTIFY_API_KEY=key bundle exec rake assets:precompile

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup ./*
RUN chmod +x /usr/src/app/docker/*

# expect/add ping environment variables
ARG VERSION_NUMBER
ARG COMMIT_ID
ARG BUILD_DATE
ARG BUILD_TAG
ENV APPVERSION=${VERSION_NUMBER}
ENV APP_GIT_COMMIT=${COMMIT_ID}
ENV APP_BUILD_DATE=${BUILD_DATE}
ENV APP_BUILD_TAG=${BUILD_TAG}
