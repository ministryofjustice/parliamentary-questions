module Features
  module EmailHelpers
    def extract_url_like(regex_string, mail)
      doc         = Nokogiri::HTML(mail.html_part.body.raw_source)
      watchlist_a = doc.css('a[href^=http]').find { |a| a['href'] =~ Regexp.new(regex_string) }
      watchlist_a['href']
    end

    def sent_mail
      ActionMailer::Base.deliveries
    end
  end
end