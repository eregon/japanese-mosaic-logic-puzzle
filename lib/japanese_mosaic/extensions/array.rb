class Array
  def surround with
    inject(with.dup) { |str, e|
      str << e.to_s << with
    }
  end
  alias_method :%, :surround
end
