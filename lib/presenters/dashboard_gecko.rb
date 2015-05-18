module Presenters
  module DashboardGecko
    module_function

    def list(gecko_object)
      @result = []
      gecko_object.each do |field|
        @result.push ({ "title" => { "text" => field.component_name },
                        "label" => { "name" => field.label, "color" => field.color },
                        "description" => field.message,
                      })
      end
      @result
    end
  end
end
