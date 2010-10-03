module JapaneseMosaic
  class Neighbors < Array
    def filled
      select(&:filled?)
    end

    def empty
      reject(&:filled?)
    end

    def fillable
      select(&:can_be_filled?)
    end

    def positive
      select { |cell| cell > 0 }
    end
  end
end
