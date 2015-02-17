# Feature Spec Documentation

## Setup

The features/ directory contains all the end-to-end tests. To run the feature tests use:

```shell
$ bundle exec rspec features/
```

The tests are configured using the helper file located in spec/feature_helper.rb. Key points to note:
* Seed data is loaded before the suite runs using the DBHelpers module (spec/support/db_helpers.rb)
* Database is cleaned using transactions by default
* If JS enabled testing is used (by setting js: true flag in the test block), Capybara will use the poltergeist driver rather than the default 
* Database cleaner uses truncation strategy for JS enabled testing (excepting the tables containing seed data)
* Tests are run in deterministic order

## Catering for Complex User Journeys

Certain scenarios and longer, more complex stories require tests to be run in a sepcific order and state maintained through a number of tests. To enable such tests set the suspend_cleaner flag to true on a feature and the database cleaner will not be run for the duration of this feature. Example usage:

```ruby
feature "Complex Story", suspend_cleaner: true do

  after(:all) do
    DatabaseCleaner.clean
  end
  
  scenario "The user should do a lot of things" do
    ...
  end
end
```

Key points to note:
* Remember to clean the database at the end of the feature (this is not done by default)
* The database is cleaned using truncation when this flag is set
