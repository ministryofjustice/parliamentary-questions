class DashboardFilter
  def initialize(count, key, label, params)
    @count  = count
    @key    = key
    @label  = label
    @params = params
  end

  def label
    @label || @key
  end

  def count
    @count || 0
  end

  def active?
    raise NotImplementedError, "The #active? method should be implemented by subclasses"
  end

  def path
    raise NotImplementedError, "the #path method should be implemented by subclassess"
  end
end
