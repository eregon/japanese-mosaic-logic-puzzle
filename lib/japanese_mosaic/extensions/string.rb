class String
  def / separator
    split(separator).tap { |result|
      result.shift while result.first.empty?
    }
  end
end
