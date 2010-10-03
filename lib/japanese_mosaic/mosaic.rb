module JapaneseMosaic
  class Mosaic
    attr_reader :mosaic, :height, :width
    def initialize file
      @mosaic = (File.open(file, &:read) / "\n").map.with_index { |row, y|
        (row / %r{\||}).map.with_index { |c, x|
          Cell.new self, c, x, y
        }
      }
      @height, @width = @mosaic.size, @mosaic.first.size
    end

    def [] i
      @mosaic[i]
    end

    include Enumerable
    def each
      return to_enum unless block_given?
      @mosaic.each { |row|
        row.each { |cell|
          yield cell
        }
      }
    end

    def inspect
      @mosaic.map { |row| row % '|' } * "\n"
    end
    def to_s
      @mosaic.map { |row| row.map(&:show) % '|' } * "\n"
    end

    # fill if all available around is the number
    def fill_exact_neighbors
      each { |cell| cell.neighbors.each(&:fill) if cell == cell.neighbors.fillable }
    end

    # can not be filled if some number has already all its cells
    # also remove cells around 0, as they can not be filled
    def remove_not_fillable
      each { |cell| cell.neighbors.empty.each(&:cannot_be_filled) if cell == cell.neighbors.filled }
    end

    def fill_under_constraint
      select { |cell| cell > 0 }.each { |cell|
        cell.neighbors_without_self.positive.each { |neighbor|
          # if all the cells around the neighbor are also around the cell, we can ignore them
          if (cell.neighbors.fillable - neighbor.neighbors).empty?
            extern_neighbors = neighbor.neighbors.fillable - cell.neighbors.fillable
            extern_neighbors.each(&:fill) if neighbor - cell == extern_neighbors.size
          end
        }
      }
    end

    def solved?
      all? { |cell| cell.empty? or cell == cell.neighbors.filled or cell.neighbors.any?(&:zero?) }
    end

    def solve
      p self and puts if $DEBUG

      loop {
        break unless Cell.change? {
          fill_exact_neighbors
          remove_not_fillable
          fill_under_constraint
        }
      }

      unless solved?
        unknown = select(&:undecided?)
        if unknown.size > 20
          warn "Sorry, I cannot solve this puzzle"
        else
          [true,false].repeated_permutation(unknown.size).find { |try|
            try.zip(unknown).each { |v, cell| v ? cell.fill : cell.cannot_be_filled }
            solved? or (unknown.each(&:reset) and false)
          }
        end
      end

      self
    end
  end
end
