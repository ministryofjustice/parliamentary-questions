
VERSION=$1

export PQ_REST_API_URL=https://api.wqatest.parliament.uk

bundle install
# Run Tesks
bundle exec rake db:drop
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake spec
