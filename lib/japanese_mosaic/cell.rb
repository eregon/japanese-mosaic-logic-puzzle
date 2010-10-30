module JapaneseMosaic
  # Three-states cell
  # true  means filled
  # nil   means undecided
  # false means it can not be filled (neighbor of a 0)
  class Cell
    class << self
      def changed!
        @change = true
      end
      def change?
        @change = false
        yield
        @change
      end
    end

    def initialize mosaic, value, x, y
      @value = value == ' ' ? nil : Integer(value)
      @mosaic, @x, @y = mosaic, x, y
    end

    def fill
      Cell.changed! and @fill = true if undecided?
    end
    def cannot_be_filled
      Cell.changed! and @fill = false if can_be_filled?
    end
    def filled?
      @fill
    end
    def can_be_filled?
      @fill != false
    end
    def cannot_be_filled?
      @fill == false
    end
    def undecided?
      @fill.nil?
    end
    def reset
      @fill = nil
    end

    def zero?
      @value == 0
    end
    def empty?
      @value.nil?
    end

    NEIGHBORS = [[1,0], [1,1], [0,1], [-1,1], [-1,0], [-1,-1], [0,-1], [1,-1]]
    def neighbors
      @neighbors ||= Neighbors.new([self] + neighbors_without_self)
    end

    def neighbors_without_self
      @neighbors_without_self ||= Neighbors.new NEIGHBORS.each_with_object([]) { |(dx,dy), neighbors|
        x, y = @x+dx, @y+dy
        if x >= 0 and y >= 0 and x < @mosaic.width and y < @mosaic.height and @mosaic[y][x].can_be_filled?
          neighbors << @mosaic[y][x]
        end
      }
    end

    def to_s
      @value ? @value.to_s : ' '
    end
    def inspect
      "#<Cell(#{@x},#{@y}) value=#{@value.inspect}#{' filled' if filled?}#{' unfillable' if cannot_be_filled?}>"
    end
    def show
      filled? ? '#' : ($DEBUG && cannot_be_filled? ? '.' : ' ')
    end

    def - cell
      @value - cell.value
    end

    def == other
      case other
      when Integer
        @value == other
      when Array
        @value == other.size
      else
        super
      end
    end

    def > other
      @value and @value > other
    end

    protected
    attr_reader :value
  end
end
