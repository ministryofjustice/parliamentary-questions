require 'uri'
module Features
  module EmailHelpers
    def extract_url_like(regex_string, mail)
      doc         = Nokogiri::HTML(mail.html_part.body.raw_source)
      watchlist_a = doc.css('a[href^=http]').find { |a| a['href'] =~ Regexp.new(regex_string) }
      if watchlist_a
        URI.parse(watchlist_a['href']).request_uri
      end
    end

    def sent_mail_to(email)
      sent_mail.select { |e| e.to.include?(email) }
    end

    def sent_mail
      ActionMailer::Base.deliveries
    end

    def clear_sent_mail
      ActionMailer::Base.deliveries = []
    end
  end
end
