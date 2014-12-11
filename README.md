parliamentary-questions
=======================

[![Build Status](https://travis-ci.org/ministryofjustice/parliamentary-questions.png?branch=master)](https://travis-ci.org/ministryofjustice/parliamentary-questions)
[![Code Climate](https://codeclimate.com/github/ministryofjustice/parliamentary-questions/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/parliamentary-questions)

# Introduction
Webapp to manage the workflow Parliamentary Questions


# Environment Variables

In order to run the project local and in production you have to set the following environment variables. Ask someone for the `set_env.sh` script.

    # username and pass for the PQ Rest Api
    PQ_REST_API_URL=<url_for_pq_api>
    PQ_REST_API_USERNAME=<username_here>
    PQ_REST_API_PASSWORD=<password_here>

    # devise authentication config
    DEVISE_SECRET=<secret_devise_token>
    DEVISE_SENDER=<email_for_email_invitation>

    # email smtp server config
    SENDING_HOST=<host_for_urls_in_emails>
    SMTP_HOSTNAME=<host>
    SMTP_PORT=<port>
    SMTP_USERNAME=
    SMTP_PASSWORD=

    # redis server, for sideqik jobs
    export REDIS_URL=redis://localhost:6379

    # host to deploy the assets (following the assets pipeline)
    ASSET_HOST=http://assets.example.com

    # version of the webapp
    APPVERSION=0.1-sprint6


# Development setup

Setup the development database and a user and some questions.

    rake db:reset
    rake db:seed:user
    rake db:seed:questions


# User authentication

It's done using devise and devise invitable:

* https://github.com/plataformatec/devise
* https://github.com/scambra/devise_invitable
