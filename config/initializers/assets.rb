Rails.application.config.assets.precompile += %w[images/favicon.ico]
Rails.application.config.assets.precompile += %w[images/favicon.svg]
Rails.application.config.assets.precompile += %w[images/govuk-icon-mask.svg]
Rails.application.config.assets.precompile += %w[images/govuk-icon-180.png]
Rails.application.config.assets.precompile += %w[images/govuk-opengraph-image.png]
Rails.application.config.assets.precompile += %w[gov.uk_logotype_crown.png]
Rails.application.config.assets.precompile += %w[font-awesome.css]
Rails.application.config.assets.precompile += %w[select2.css]
Rails.application.config.assets.precompile += %w[select2-bootstrap.css]
Rails.application.config.assets.precompile += %w[vendor/jquery.datetimepicker.css]
Rails.application.config.assets.precompile += %w[vendor/pq-select2.css]
# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w[ admin.js admin.css ]
Rails.application.config.assets.paths << Rails.root.join("node_modules")
Rails.application.config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets")
