parliamentary-questions
=======================

[![Build Status](https://travis-ci.org/ministryofjustice/parliamentary-questions.png?branch=master)](https://travis-ci.org/ministryofjustice/parliamentary-questions)
[![Code Climate](https://codeclimate.com/github/ministryofjustice/parliamentary-questions/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/parliamentary-questions)

# Introduction
Webapp to manage the workflow Parliamentary Questions

# Environment Variables

```
# username and pass for the PQ Rest Api
PQ_REST_API_HOST=<url_for_pq_api>

While developing or running automated tests, you can use the built-in mock API server by
setting this value to: http://localhost:8888

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

# FOR PRODUCTION ONLY...

# Path to ssl certs
CA_CERT=/etc/ssl/certs/
# number of unicorn workers
WEB_CONCURRENCY=4

# host to deploy the assets (following the assets pipeline)
ASSET_HOST=http://assets.example.com

# version of the webapp
APPVERSION=0.1-sprint6
```

# System dependencies

- Ruby MRI 2.1.2
- Postgresql 9.3
- phantomjs (tests only)
- coreutils (for required by the `version_tag.sh` script)

To start with, make sure you have the right version of the Ruby runtime installed.
Multiple versions of Ruby can be managed on the same machine through either [rbenv](https://github.com/sstephenson/rbenv)
or [rvm](https://rvm.io/).

The Postgresql version used in production is 9.3. This can be installed via [homebrew](brew.sh):

    brew install homebrew/versions/postgresql93

# Project setup

Install the app dependencies by running the following

    gem install bundler && bundle install

If you get problems installing the pg gem not being able to find libpg, try setting the architecture flag as follows:

    gem install bundler && ARCHFLAGS="-arch x86_64" bundle install

You can now procede setting up the database table layout

    bundle exec rake db:setup

And starting the app with:

    bundle exec rails s

Mock data can be automatically imported by running the following rake task:

    bundle exec rake pqa:import_dummy_data

Finally, a rake task is also provided to load PQ&A XML data into the system.

    bundle exec rake pqa:import_from_xml[path/to/question_file.xml]

# User authentication

It's done using devise and devise invitable:

* https://github.com/plataformatec/devise
* https://github.com/scambra/devise_invitable

For development you can create users with a rake task.
```
# default user
rake user:create

# specific email, password, name
rake "user:create[admin@admin.com, 123456789, admin]"
```

# Running tests

Unit tests can be run via `bundle exec rspec`, while end-to-end tests can
be run be executing the same command with the features folder as argument (i.e.
`bundle exec rspec features`).
