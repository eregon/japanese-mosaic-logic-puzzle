module JapaneseMosaic
  module Neighborhood
    def filled
      select(&:filled?)
    end

    def empty
      reject(&:filled?)
    end

    def fillable
      select(&:fillable?)
    end

    def positive
      select { |cell| cell > 0 }
    end
  end
end
