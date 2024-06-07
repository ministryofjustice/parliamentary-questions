# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("config/application", __dir__)

ParliamentaryQuestions::Application.load_tasks

# Disable the requirement for pg_dump on production
Rake::Task["db:schema:dump"].clear if Rails.env.production?
