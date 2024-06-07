module XmlExtractor
module_function

  def datetime(node, xpath)
    v = text(node, xpath)
    # v && Time.zone.parse(v)
    v && DateTime.parse(v) # rubocop:disable Style/DateTime
  end

  def int(node, xpath)
    v = text(node, xpath)
    v&.to_i
  end

  def text(node, xpath)
    el = node.at(xpath)
    el&.text
  end

  def bool(node, xpath)
    case text(node, xpath)
    when "false"
      false
    when "true"
      true
    end
  end
end
