<div align="center">

<a id="readme-top"></a>

<br>

<img alt="MoJ logo" src="https://moj-logos.s3.eu-west-2.amazonaws.com/moj-uk-logo.png" width="200">

## Parliamentary Questions

[![CircleCI](https://circleci.com/gh/ministryofjustice/parliamentary-questions.svg?style=svg)](https://circleci.com/gh/ministryofjustice/parliamentary-questions)
[![repo standards badge](https://img.shields.io/endpoint?labelColor=231f20&color=005ea5&style=for-the-badge&label=MoJ%20Compliant&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fapi%2Fv1%2Fcompliant_public_repositories%2Fendpoint%2Fparliamentary-questions&logo=data:image/png;base64,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)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-report/parliamentary-questions)

</div>

# Introduction
Webapp to manage the workflow Parliamentary Questions

# System dependencies

- Ruby 3.1.4
- Postgresql 9.3
- phantomjs  (tests only)
- coreutils (required by the `version_tag.sh` script)
- graphviz (required by the `bin/generate-erd` script)

To start with, make sure you have the right version of the Ruby runtime installed.
Multiple versions of Ruby can be managed on the same machine through either [rbenv](https://github.com/sstephenson/rbenv)
or [rvm](https://rvm.io/).

The Postgresql version used in production is 9.3. This can be installed via [homebrew](brew.sh):

    brew install homebrew/versions/postgresql93

# Project setup

Start by setting the required environment variables. The included `.env.sample` file will show you which ones you will need as a bare minimum.

Then Install the app dependencies by running the following

    gem install bundler && bundle install

### Installation Issues

There maybe an issue installing `eventmachine` on an M1 mac. This maybe solved by running

    gem install eventmachine -v '1.2.7' -- --with-ldflags="-Wl,-undefined,dynamic_lookup"
    bundle install

If you get problems installing the `pg` gem not being able to find libpg, try setting the architecture flag as follows:

    gem install bundler && ARCHFLAGS="-arch x86_64" bundle install

---

You can now proceed setting up the database table layout

    bundle exec rake db:setup

Note: If you get error: FATAL: role “postgres” does not exist then double check that postgres is successfully installed and running then try this:

    createdb testDB
    psql -U <your MAC username>

  Once entered into postgres command line type this all on one line:

    CREATE ROLE postgres WITH
    LOGIN SUPERUSER INHERIT CREATEDB CREATEROLE NOREPLICATION;

  Then try the db setup command above again. You can customise the DB user and password by setting the ENV variables `DB_USERNAME` and `DB_PASSWORD`.

And starting the app with:

    bundle exec rails s

Mock data can be automatically imported by running the following rake task (it will make use of a mock API server running on localhost:8888 so make sure this port is free):

    bundle exec rake pqa:import_dummy_data

Finally, a rake task is also provided to load PQ&A XML data into the system.

    bundle exec rake pqa:import_from_xml[path/to/question_file.xml]

## Running the tests

In order to run the tests, you can use:

```sh
bundle exec rake
```

This will run specs and rubocop linting. Or you can run them individually, with `rake rubocop` and `rake spec`.

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

## Keeping secrets secure

There should be *absolutely no secure credentials* committed in this repo. Information about secret management can be found in the related confluence pages.

# Data model

![PQ entity-relations diagram](https://github.com/ministryofjustice/parliamentary-questions/blob/dev/erd.png)

An entity-relationship diagram of PQ's data model can be generated by running
the `bin/generate-erd` script. Please do re-run this script to update the graph as
the application schema evolves.

# Running tests

Unit tests can be run via `bundle exec rspec`, while end-to-end tests can
be run be executing the same command with the features folder as argument (i.e.
`bundle exec rspec features`). Please refer to the [readme](https://github.com/ministryofjustice/parliamentary-questions/tree/dev/features) in the features folder
for end-to-end tests implementation details.

# Emails
Emails are sent using the [GOVUK Notify service](https://www.notifications.service.gov.uk).

Please refer to the [readme](https://github.com/ministryofjustice/parliamentary-questions/tree/dev/app/mailers)in the mailers folder
for details of how to get an account and obtain an API key.

## Dependabot

Dependabot creates PRs to help us keep track of our dependency updates. This is great but can lead to a little bit of work if you integrate these changes one by one (for instance, having to run the test suite over and over again).

You can manually combine the changes into one PR and then push this and wait for the tests to run, but this is admin that can be automated so why bother?

The app has a github action "Combine PRs" which automatically combines dependabot PRs that have passed the test suite into one PR which you can then merge.

To use this: "Actions" > "All workflows" > on the left "Combine PRs" > "Run workflows"

See here for the [original developers README](https://github.com/hrvey/combine-prs-workflow)
