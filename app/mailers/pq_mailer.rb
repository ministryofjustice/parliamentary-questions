class PqMailer < PqBaseMailer
  default from: Settings.mail_from
  def commit_email(template_params)

  	@template_params = template_params
  	# email, name from AO
  	# uin, question from PQ
  	# url with the token
    mail(to: @template_params[:email], subject: "[Parliamentary-Questions] #{@template_params[:uin]} | You have been allocated a question")
  end
end
