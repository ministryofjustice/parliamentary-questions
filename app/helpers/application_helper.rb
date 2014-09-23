module ApplicationHelper
  class ActionView::Helpers::FormBuilder
    # http://stackoverflow.com/a/2625727/1935918
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::FormOptionsHelper
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::AssetTagHelper
    def gds_check_box(attribute_name, *args)
      @template.content_tag 'div', class:'form-group wibble' do


        @template.content_tag 'label', 'text', class: 'wibblelabel', for: 'a_control' do end


        @template.content_tag 'label', class: 'block-label selected', for: "#{@object_name}[#{attribute_name}]" do
          # options = args.extract_options!
          # options[:include_hidden] = false
          # args << options
          @template.hidden_field_tag @object_name, attribute_name , value: '0'
          check_box_tag("#{@object_name}[#{attribute_name}]") + @object.class.human_attribute_name(attribute_name)
        end
      end
    end
  end

  def flash_class_for flash_type
    case flash_type
      when :success
        "alert-success"
      when :error
        "alert-danger"
      when :alert
        "alert-block"
      when :notice
        "alert-info"
      else
        flash_type.to_s
    end
  end
end
