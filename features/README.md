# Feature Spec Documentation

## Setup

The features/ directory contains all the end-to-end tests. To run the feature tests use:

```shell
$ bundle exec rspec features/
```

The tests are configured using the helper file located in spec/feature_helper.rb. Key points to note:
* Seed data is loaded before the suite runs using the DbHelpers module (spec/support/db_helpers.rb)
* Database is cleaned using transactions by default
* If JS enabled testing is used (by setting js: true flag in the test block), Capybara will use the poltergeist driver rather than the default
* Database cleaner uses truncation strategy for JS enabled testing (excepting the tables containing seed data)

Key points to note:
* Remember to clean the database at the end of the feature (this is not done by default)
* The database is cleaned using truncation when this flag is set
