# Environment Variables

This is an up to date list of the environment variables used by the app.
Refer to the provisioning code for the actual values expected to be set on each
specific environment.

For local development, the only mandatory variables are `PQ_REST_API_HOST` and `TEST_USER_PASS`. `PQ_REST_API_HOST` should
be set to `http://localhost:8888`, as it is the default hostname/port used
by the [mock implementation](https://github.com/ministryofjustice/parliamentary-questions/blob/dev/lib/pqa/mock_api_server_runner.rb)
of Parliament's Question and Answer API. `TEST_USER_PASS` can be set to any value.

Variable Name          |Required for local development  | Description
-----------------------| ------------------------------ | -----------------------------
`PQ_REST_API_HOST`     | y                              | Hostname of the Parlamentary Question and Answers API
`PQ_REST_API_USERNAME` | n                              | Username
`PQ_REST_API_PASSWORD` | n                              | Password
`DEVISE_SECRET`        | n                              | Secret Devise Token
`DEVISE_SENDER`        | n                              | Email address used for signup/signin/password related notifications
`SENDING_HOST`         | n                              | Host for URLs in emails
`SMTP_HOSTNAME`        | n                              | SMTP server host
`SMTP_PORT`            | n                              | SMTP server port
`SMTP_USERNAME`        | n                              | SMTP user name
`SMTP_PASSWORD`        | n                              | SMPT password
`CA_CERT`              | n                              | Absolute Path of the system's SSL certificates dir (e.g. `/etc/ssl/certs`)
`WEB_CONCURRENCY`      | n                              | Number of unicorn workers to be spawned at startup time
`ASSET_HOST`           | n                              | Host where Rails' assets pipeline will deploy the assets
`APPVERSION`           | n                              | The current application version tag
`TEST_USER`            | n                              | The current application version tag
`TEST_USER_PASS`       | y                              | The password for the test users created by `rake db:staging:sync` and smoke tests
