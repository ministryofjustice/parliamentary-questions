module PQA
  class Question
    attr_accessor :uin,
                  :updated_date,
                  :date_for_answer,
                  :tabled_date,
                  :answering_body_id,
                  :answering_body_name,
                  :answering_body_short_name,
                  :house_id,
                  :house_name,
                  :member_id,
                  :member_name,
                  :member_constituency,
                  :question_status,
                  :question_type,
                  :registered_interest,
                  :session,
                  :target,
                  :text,
                  :session_number,
                  :url,
                  :version_number,
                  :parliament_number

    def self.from_xml(element)
      xml                         = ::XmlExtractor
      q                           = new

      q.uin                       = xml.text(element, "Uin")
      q.updated_date              = xml.datetime(element, "UpdatedDate")
      q.date_for_answer           = xml.datetime(element, "DateForAnswer")
      q.tabled_date               = xml.datetime(element, "TabledDate")

      q.answering_body_id         = xml.text(element, "AnsweringBody/AnsweringBodyId")
      q.answering_body_name       = xml.text(element, "AnsweringBody/AnsweringBodyName")
      q.answering_body_short_name = xml.text(element, "AnsweringBody/AnsweringBodyShortName")
      q.house_id                  = xml.text(element, "House/HouseId")
      q.house_name                = xml.text(element, "House/HouseName")
      q.member_id                 = xml.text(element, "TablingMember/MemberId")
      q.member_name               = xml.text(element, "TablingMember/MemberName")
      q.member_constituency       = xml.text(element, "TablingMember/Constituency")
      q.question_status           = xml.text(element, "QuestionStatus")
      q.question_type             = xml.text(element, "QuestionType")

      q.registered_interest       = xml.bool(element, "RegisteredInterest")

      q.session                   = xml.text(element, "Session")
      q.target                    = xml.text(element, "Target")
      q.text                      = xml.text(element, "Text")
      q.url                       = xml.text(element, "Url")

      q.version_number            = xml.int(element, "VersionNumber")
      q.parliament_number         = xml.int(element, "ParliamentNumber")
      q.session_number            = xml.int(element, "SessionNumber")
      q
    end
  end
end
