module XMLExtractor
  module_function
  def datetime(node, xpath)
    v = text(node, xpath)
    v && DateTime.parse(v)
  end

  def int(node, xpath)
    v = text(node, xpath)
    v && v.to_i
  end

  def text(node, xpath)
    el = node.at(xpath)
    el && el.text
  end

  def bool(node, xpath)
    case text(node, xpath)
    when 'false'
      false
    when 'true'
      true
    end
  end
end
