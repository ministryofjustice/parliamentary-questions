class GeckoStatus
  attr_accessor :label, :color, :message
  attr_reader   :component_name

  def initialize(component_name)
    @component_name = component_name
    @label = "n/a"
    @color = 'red'
    @message = 'unitialized'
  end

  def warn(message)
    @label = 'WARNING'
    @color = 'yellow'
    @message = message
  end

  def error(message)
    @label = 'ERROR'
    @color = 'red'
    @message = message
  end

  def ok(message = "")
    @label = 'OK'
    @color = 'green'
    @message = message
  end
end
