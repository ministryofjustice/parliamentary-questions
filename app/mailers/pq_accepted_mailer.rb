class PQAcceptedMailer < PQBaseMailer
  default from: Settings.mail_from
  def commit_email(pq, ao, urgent = false)

    @template_params = Hash.new
    @template_params[:name] = ao.name
    @template_params[:email] = ao.email
    @template_params[:uin] = pq.uin
    @template_params[:question] = pq.question
    @template_params[:mpname] = pq.minister.name unless pq.minister.nil?
    @template_params[:mpemail] = pq.minister.email unless pq.minister.nil?
    @template_params[:policy_mpname] = pq.policy_minister.name unless pq.policy_minister.nil?
    @template_params[:policy_mpemail] = pq.policy_minister.email unless pq.policy_minister.nil?
    @template_params[:press_email] = ao.press_desk.email_output unless ao.press_desk.nil?


    mp_cc_list = [
        'Christopher.Beal@justice.gsi.gov.uk',
        'Nicola.Calderhead@justice.gsi.gov.uk',
        'thomas.murphy@JUSTICE.gsi.gov.uk'
    ]

    cc_list = [
        @template_params[:mpemail],
        @template_params[:policy_mpemail],
        @template_params[:press_email]
    ]

    # add the mp_cc_list if the minister is 'Simon Hughes'
    if !pq.minister.nil? && pq.minister.name == 'Simon Hughes'
      cc_list.append(mp_cc_list)
    end

    @template_params[:cc_list] = cc_list.join(';')

    if urgent
      subject = "[Parliamentary-Questions] #{@template_params[:uin]} | URGENT please send the draft for the question that you have accepted"
    else
      subject = "[Parliamentary-Questions] #{@template_params[:uin]} | You have accepted the question"
    end


    # email, name from AO
    # uin, question from PQ
    mail(to: @template_params[:email], subject: subject)
  end
end
