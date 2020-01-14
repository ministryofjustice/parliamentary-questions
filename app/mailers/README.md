# Setting up and using GovUK Notify

## Getting a GovUK Notify account

You need an account before you can use [GOV.UK Notify](https://www.notifications.service.gov.uk) to send emails. To obtain one ask a current member of the team to add you to the PQ tracker service, by navigating to the `Team members` page and clicking the `Invite a team member` button and entering a government email address. This will send an email inviting you to use the service.

## Getting a key for local development

- Sign into [GOV.UK Notify](https://www.notifications.service.gov.uk)
- Go to the ‘API integration’ page
- Click ‘API keys’
- Click the ‘Create an API’ button
- Choose the ‘Test’ option.
- Copy your key and add it to your `.bashprofile` with the name `GOVUK_NOTIFY_API_KEY` as in the [environment variables readme](https://github.com/ministryofjustice/parliamentary-questions/tree/dev/config)

We use test keys in local development to ensure we do not send out too many emails. If it is necessary to send emails from your local machine, you can use a `Team and whitelist` API key.

## Accessing information in the Notify service

Once you have an account you can view the `Dashboard` with details of how many emails have been sent out and any that have failed to send. 

You can update the content of the emails in the `Templates` section.

## For more information

Documentation for GovUK Notify can be found here: https://docs.notifications.service.gov.uk/ruby.html

The status of GovUK notify can be checked here: https://status.notifications.service.gov.uk/

For more information the Notify team can be contacted here: https://www.notifications.service.gov.uk/support, or in the UK Government digital slack workspace in the #govuk-notify channel.

