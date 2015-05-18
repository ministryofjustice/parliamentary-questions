module Presenters
  module DashboardGecko
    module_function

    def json_report(gecko_object)
      list(gecko_object).to_json
    end

    private_class_method

    def list(gecko_object)
      gecko_object.map do |fields|
        { 
          "title"       => { "text" => fields.name },
          "label"       => { "name" => fields.label, "color" => fields.color },
          "description" => fields.message,
        }
      end
    end
  end
end
