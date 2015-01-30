module PQA
  class Question
    attr_accessor :uin, :updated_date, :date_for_answer, :tabled_date,
                  :answering_body_id, :answering_body_name, :answering_body_short_name,
                  :house_id, :house_name, :member_id, :member_name, :member_constituency,
                  :question_status, :question_type, :registered_interest,
                  :session, :target, :text, :session_number, :uri, :version_number,
                  :parliament_number

    def self.from_xml(el)
      xml                         = ::XMLExtractor
      q                           = new

      q.uin                       = xml.text(el, 'Uin')
      q.updated_date              = xml.datetime(el, 'UpdatedDate')
      q.date_for_answer           = xml.datetime(el,'DateForAnswer')
      q.tabled_date               = xml.datetime(el,'TabledDate')

      q.answering_body_id         = xml.text(el,'AnsweringBody/AnsweringBodyId')
      q.answering_body_name       = xml.text(el,'AnsweringBody/AnsweringBodyName')
      q.answering_body_short_name = xml.text(el,'AnsweringBody/AnsweringBodyShortName')
      q.house_id                  = xml.text(el,'House/HouseId')
      q.house_name                = xml.text(el,'House/HouseName')
      q.member_id                 = xml.text(el,'TablingMember/MemberId')
      q.member_name               = xml.text(el,'TablingMember/MemberName')
      q.member_constituency       = xml.text(el,'TablingMember/Constituency')
      q.question_status           = xml.text(el,'QuestionStatus')
      q.question_type             = xml.text(el,'QuestionType')

      q.registered_interest       = xml.bool(el,'RegisteredInterest')

      q.session                   = xml.text(el,'Session')
      q.target                    = xml.text(el,'Target')
      q.text                      = xml.text(el,'Text')
      q.uri                       = xml.text(el,'Url')

      q.version_number            = xml.int(el,'VersionNumber')
      q.parliament_number         = xml.int(el,'ParliamentNumber')
      q.session_number            = xml.int(el,'SessionNumber')
      q
    end
  end
end
