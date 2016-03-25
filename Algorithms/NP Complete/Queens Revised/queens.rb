#!/usr/bin/env ruby
#
# Place N queens on an NxN board while observing that:
#
#   1. no 2 queens can be in the same row
#   2. no 2 queens can be in the same column
#   3. no 2 queens can see each other diagonally (45 or 135 deg)
#   4. no 3 queens should see each other diagonally (any deg)
#
# To generate RDoc documentationm from this file:
#
# $ rdoc queens.rb


# This class represents a position in the board.
class Position
  # The position's row.
  attr_accessor :row

  # The position's column.
  attr_accessor :col

  # Creates a new position with a given row and column.
  # +row+:: the row
  # +col+:: the column
  def initialize(row, col)
    @row = row
    @col = col
  end
end


# This class represents a queen.
class Queen
  # The queen's position on the board.
  attr_accessor :pos

  # Creates a new queen at a position.
  # +pos+:: the position
  def initialize(pos)
    @pos = pos
  end

  # Moves the queen to a new position.
  # +pos+:: the new position
  def move(pos)
    @pos = pos
  end

  # Returns whether this queen attacks another queen in any way.
  # +queen+:: the other queen
  def attacks?(queen)
    return true if attacks_vertically?(queen)
    return true if attacks_horizontally?(queen)
    return true if attacks_diagonally?(queen)
    false
  end

  # Returns whether this queen attacks another queen vertically.
  # +queen+:: the other queen
  def attacks_vertically?(queen)
    @pos.col == queen.pos.col
  end

  # Returns whether this queen attacks another queen horizontally.
  # +queen+:: the other queen
  def attacks_horizontally?(queen)
    @pos.row == queen.pos.row
  end

  # Returns whether this queen attacks another queen diagonally.
  # +queen+:: the other queen
  def attacks_diagonally?(queen)
    (@pos.row - queen.pos.row).abs == (@pos.col - queen.pos.col).abs
  end
end


# This class represents an N x N game board.
class Board
  # The queens on the board, orderd by row.
  attr_reader :queens

  # Creates a new game board with the queens randomly distributed.
  # +n+:: the number of queens, rows and columns on the board
  def initialize(n)
    @queens = Array.new(n) { |row| Queen.new(Position.new(row, Random.rand(n))) }
  end

  # Returns the number of queens under attack.
  def attack_count
    @queens.select { |q| attacked?(q) }.uniq.count
  end

  # Returns whether a queen is under attack from any other queen.
  # +queen+:: the queen
  def attacked?(queen)
    others = queens - [queen]
    return true if others.any? { |q| q.attacks?(queen) }
    others.each_with_index do |a, index|
      rest = others[index+1..-1] || []
      return true if rest.any? { |b| straight_line?(a, b, queen) }
    end
    false
  end

  # Returns whether three queens are in any straight line.
  # +a+:: the first queen
  # +b+:: the second queen
  # +c+:: the third queen
  def straight_line?(a, b, c)
    dr_ab = a.pos.row - b.pos.row
    dc_ab = a.pos.col - b.pos.col
    dr_bc = b.pos.row - c.pos.row
    dc_bc = b.pos.col - c.pos.col
    dr_ab * dc_bc == dr_bc * dc_ab
  end

  # Returns a list of positions, representing the moves the queen can make in
  # her row.
  # +queen+:: the queen
  def row_moves(queen)
    cols = (0..@queens.count-1).to_a - [queen.pos.col]
    cols.map { |col| Position.new(queen.pos.row, col) }
  end

  # Returns a string representation of the board, as a whitespace-delimited
  # sequence of column of queens, sorted by row.
  # +visual+:: when true, also includes a 2D board depiction
  def to_s(visual = true)
    s = @queens.map { |queen| queen.pos.col + 1 }.join(' ')
    if visual
      s += "\n" + @queens.map do |queen|
        line = '.' * @queens.count
        line[queen.pos.col] = 'Q'
        line
      end.join("\n")
    end
    s
  end
end


# This class solves the Queens Revisited problem.
class Solver

  # Applies First-choice Random-restart Hill Climbing to solve the Queens
  # Revisited problem. It has the limitation that if no solution exists, it
  # will continue searching indefinitely.
  # +n+:: the number of queens to place on an n x n board
  def solve(n)
    while true
      @board = Board.new(n)
      before = attacked = @board.attack_count
      while attacked != nil and attacked > 0
        before = attacked
        attacked = first_choice(attacked)
      end
      return @board if attacked == 0
    end
  end

  # Moves the first queen that results in a reduction of the attack count and
  # returns the new attack count. Returns nil if no queen's movement reduces the
  # attack count.
  # +before+:: the current attack count
  def first_choice(before)
    @board.queens.each do |queen|
      @board.row_moves(queen).each do |pos|
        home = queen.pos
        queen.move(pos)
        attacked = @board.attack_count
        return attacked if attacked < before
        queen.move(home)
      end
    end
    nil
  end
end


# Retrieves the sizes of the (square) board from the user and prints each
# solution to the Queens Revisited problem for a board of that size.  Each
# solution is printed as a list of queen columns, ordered by row, and as a
# visual board layout.
n = (ARGV.shift || gets).to_i
solution = Solver.new.solve(n)
if solution
  puts solution
else
  puts "No solution for n=#{n}"
end
