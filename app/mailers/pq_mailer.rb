class PqMailer < PQBaseMailer
  default from: Settings.mail_from
  def commit_email(template_params)
  	@template_params = template_params
  	# email, name from AO
  	# uin, question from PQ
  	# url with the token
    mail(to: @template_params[:email], subject: "You have been allocated PQ #{@template_params[:uin]}")
  end
  def notify_dd_email(template_params)
    @template_params = template_params
    mail(to: @template_params[:email], subject: "#{@template_params[:ao_name]} has been allocated PQ #{@template_params[:uin]}")
  end

end
