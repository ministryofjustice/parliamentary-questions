parliamentary-questions
=======================

[![Build Status](https://travis-ci.org/ministryofjustice/parliamentary-questions.png?branch=master)](https://travis-ci.org/ministryofjustice/parliamentary-questions)
[![Code Climate](https://codeclimate.com/github/ministryofjustice/parliamentary-questions/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/parliamentary-questions)

# Introduction
Webapp to manage the workflow Parliamentary Questions

# Environment Variables

In order to run the project local and in production you have to set the following environment variables

```
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
```

# System dependencies

- Ruby MRI 2.1.2
- Postgresql 9.3

To start with, make sure you have the right version of the Ruby runtime installed.
Multiple versions of Ruby can be managed on the same machine through either [rbenv](https://github.com/sstephenson/rbenv)
or [rvm](https://rvm.io/).

The Postgresql version used in production is 9.3. This can be installed via [homebrew](brew.sh):

    brew install homebrew/versions/postgresql93

# Project setup

Install the app dependencies by running the following

    gem install bundler && bundle install

You can now procede setting up the database table layout

    bundle exec rake db:setup

And starting the app with:

    bundle exec rails s

Finally, mock data can be automatically imported by just pointing your browser to
this URL:

    http://localhost:3000/import/questions_force_update?dateFrom=2014-05-01&dateTo=2015-01-12

Refer to the [Mock PQ API](https://github.com/ministryofjustice/mock-pq-api) Readme
file for further details on the mock dataset.

# User authentication

It's done using devise and devise invitable:

* https://github.com/plataformatec/devise
* https://github.com/scambra/devise_invitable

For development you can create users with a rake task.
```
# email, password, name
rake "user:create[admin@admin.com, 123456789, admin]"
```

# Data migration

The import_transform task takes two parameters:
* the path to the file you want to import
* optional boolean parameter to show the full script of the sql commands being run [default is true]
```
# path to local import text file.
# the file should be tilde(~) delimited, not tab
rake db:import_transform['/users/yourname/path/to/filename.txt', false] --trace
```
