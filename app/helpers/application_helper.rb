module ApplicationHelper
  class ActionView::Helpers::FormBuilder
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::FormOptionsHelper
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::AssetTagHelper

    def check_box_gds(attribute_name, *args)
      checked = 'checked="checked"' if @template.check_box(@object_name, attribute_name).include? 'checked="checked"'
      html = <<-HTML
      <div class="form-group">
        <input type="hidden" name="#{@object_name}[#{attribute_name}]" value=0 />
      	<label for="#{@object_name}_#{attribute_name}" class="block-label">
         <input id="#{@object_name}_#{attribute_name}" name="#{@object_name}[#{attribute_name}]" type="checkbox" value="1" #{checked}/>
          #{@object.class.human_attribute_name(attribute_name)}
      	</label>
      </div>
      HTML
      html.html_safe
    end
  end

  def flash_class_for(flash_type)
    Rails.logger.info flash_type
    case flash_type.to_s
    when 'notice'
      'pq-msg-notice'
    when 'success'
      'pq-msg-success'
    when 'error'
      'pq-msg-error'
    when 'alert'
      'pq-msg-warning'
    else
      'pq-msg-success'
    end
  end

  def minister_warning?(question, minister)
    question.present? && question.open? && minister.try(:deleted?)
  end
end
