FROM ruby:3.1.4-alpine
LABEL key="Ministry of Justice, Parlimentary Questions"
RUN set -ex

RUN addgroup --gid 1000 --system appgroup && \
    adduser --uid 1000 --system appuser --ingroup appgroup

RUN apk --no-cache add --virtual build-dependencies build-base libc-dev libxml2-dev libxslt-dev openssl-dev \
    && apk --no-cache add bash curl file libpq linux-headers nodejs postgresql-dev tzdata tini postgresql-client less

RUN apk -U upgrade

# set WORKDIR
WORKDIR /usr/src/app

COPY Gemfile* .ruby-version ./
RUN gem install bundler -v 2.4.19

RUN bundle config deployment true && \
    bundle config without development test && \
    bundle install --jobs 4 --retry 3

COPY . .

RUN mkdir log tmp
RUN chown -R appuser:appgroup /usr/src/app/
USER appuser
USER 1000

RUN RAILS_ENV=production PQ_REST_API_HOST=localhost PQ_REST_API_USERNAME=user PQ_REST_API_PASSWORD=pass DEVISE_SECRET=secret bundle exec rake assets:precompile

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup ./*
RUN chmod +x /usr/src/app/docker/*

# expect/add ping environment variables
ARG APP_GIT_COMMIT
ARG APP_BUILD_DATE
ARG APP_BUILD_TAG
ENV APP_GIT_COMMIT=${APP_GIT_COMMIT}
ENV APP_BUILD_DATE=${APP_BUILD_DATE}
ENV APP_BUILD_TAG=${APP_BUILD_TAG}
