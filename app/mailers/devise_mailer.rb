class DeviseMailer < Devise::Mailer
  # Optional. eg. `confirmation_url`
  include Devise::Controllers::UrlHelpers

  def confirmation_instructions(record, token, _opts = {})
    set_template('13bb4127-f20d-43a9-9e53-bff17f2537c4')

    set_personalisation(
      email_subject: 'Confirm account',
      name: record.name,
      confirmation_url: confirmation_url(record, confirmation_token: token)
    )

    mail(to: record.email)
  end

  def invitation_instructions(record, token, _opts = {})
    set_template('a0a7f661-5096-4344-9627-a00a6f1f2db1')

    set_personalisation(
      email_subject: 'Invitation instructions',
      name: record.name,
      accept_invitation_url: accept_user_invitation_url(record, invitation_token: token),
      mail_reply_to: Settings.mail_reply_to
    )

    mail(to: record.email)
  end

  def reset_password_instructions(record, token, _opts = {})
    set_template('63f161f8-79b7-4ca0-99f7-137c101dcbb5')

    set_personalisation(
      email_subject: 'Confirm account',
      name: record.name,
      edit_password_url: edit_password_url(record, reset_password_token: token)
    )

    mail(to: record.email)
  end

  def unlock_instructions(record, token, _opts = {})
    set_template('ba4c3c23-f73f-4b8d-84ca-433ad060352b')

    set_personalisation(
      email_subject: 'Confirm account',
      name: record.name,
      unlock_url: unlock_url(record, unlock_token: token)
    )

    mail(to: record.email)
  end
end
