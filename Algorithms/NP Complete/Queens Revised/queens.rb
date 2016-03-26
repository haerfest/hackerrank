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

  # Returns a string representation.
  def to_s
    "(#{row+1},#{col+1})"
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

  # Returns whether a queen attacks another queen.
  # +queen+:: the queen
  def attacks?(queens)
    return true if queens.any? do |q|
      vertically?(q) or horizontally?(q) or diagonally?(q)
    end
    queens.each_with_index do |q1, index|
      rest = queens[index+1..-1] || []
      return true if rest.any? { |q2| line?(self, q1, q2) }
    end
    false
  end

  # Returns whether this queen attacks another queen vertically.
  # +queen+:: the other queen
  def vertically?(queen)
    @pos.col == queen.pos.col
  end

  # Returns whether this queen attacks another queen horizontally.
  # +queen+:: the other queen
  def horizontally?(queen)
    @pos.row == queen.pos.row
  end

  # Returns whether this queen attacks another queen diagonally.
  # +queen+:: the other queen
  def diagonally?(queen)
    (@pos.row - queen.pos.row).abs == (@pos.col - queen.pos.col).abs
  end

  # Returns whether three queens are in any straight line.
  # +a+:: the first queen
  # +b+:: the second queen
  # +c+:: the third queen
  def line?(a, b, c)
    dr_ab = a.pos.row - b.pos.row
    dc_ab = a.pos.col - b.pos.col
    dr_bc = b.pos.row - c.pos.row
    dc_bc = b.pos.col - c.pos.col
    dr_ab * dc_bc == dr_bc * dc_ab
  end

  # Returns a string representation.
  def to_s
    "queen@#{pos}"
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

  # Returns the queens that attack other queens.
  def attacking_queens
    @queens.select { |q| q.attacks?(@queens - [q]) }
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
  def to_a
    @queens.map { |queen| queen.pos.col + 1 }
  end

  # Returns a string representation.
  def to_s
    @queens.map do |queen|
      line = '.' * @queens.count
      line[queen.pos.col] = 'Q'
      line
    end.join("\n")
  end
end


# This class solves the Queens Revisited problem.
class Solver

  # Constructor.
  # +debug+:: when true, prints debug information while solving
  def initialize(debug = false)
    @debug = debug
  end

  # Applies Min-Conflicts to solve the Queens Revisited problem, returning a
  # solution or nil if there is no solution.
  # +n+:: the number of queens to place on an n x n board
  # +max_steps+:: the maximum number of steps to take
  def solve(n, max_steps = 100)
    @board = Board.new(n)
    max_steps.times do |step|
      puts "\nstep ##{step+1}:\n#{@board}" if @debug
      attacking = @board.attacking_queens
      puts 'attacking: ' + attacking.map { |q| q.to_s }.join(',') if @debug
      return @board if attacking.count == 0
      attacker = attacking[rand(attacking.count)]
      puts "conflicted attacker: #{attacker}" if @debug
      pos, _ = min_conflicts(attacker)
      puts "moving attacker to: #{pos}" if @debug
      attacker.move(pos)
    end
    nil
  end

  def min_conflicts(queen)
    moves = @board.row_moves(queen).map do |pos|
      [pos, conflicts(queen, pos)]
    end.sort do |a, b|
      _, n1 = a
      _, n2 = b
      n1 <=> n2
    end
    puts 'moves: ' + moves.map { |p,n| "#{p}:#{n}" }.join(',') if @debug
    winner = moves.shift
    _, n = winner
    winners = [winner] + moves.take_while { |_, m| n == m }
    puts 'winners: ' + winners.map { |p,n| "#{p}:#{n}" }.join(',') if @debug
    winners[rand(winners.count)]
  end

  # Returns the number of queens that will be under attack after moving one
  # queen to a new position.
  # +queen+:: the queen to move
  # +pos+:: the position to move her to
  def conflicts(queen, pos)
    home = queen.pos
    queen.move(pos)
    n = @board.attacking_queens.count
    queen.move(home)
    n
  end

end


# Retrieves the sizes of the (square) board from the user and prints each
# solution to the Queens Revisited problem for a board of that size.  Each
# solution is printed as a list of queen columns, ordered by row, and as a
# visual board layout.
srand
n = (ARGV.shift || gets).to_i
solution = Solver.new.solve(n, 1_000_000_000)
if solution
  puts solution.to_a.join(' ')
  puts solution
else
  puts "No solution for n=#{n}"
end
