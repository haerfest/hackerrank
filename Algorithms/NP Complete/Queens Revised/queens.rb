#!/usr/bin/env ruby
#
# Place N queens on an NxN board while observing that:
#
#   1. no 2 queens can be in the same row
#   2. no 2 queens can be in the same column
#   3. no 2 queens can see each other diagonally (45 or 135 deg)
#   4. no 3 queens should see each other diagonally (any deg)
#
# Strategy:
#
#   1. Starting at row 1, place a queen at the first available column and mark
#      all possitions that are not allowed anymore:
#
#   Q x x x x
#   x x . . .
#   x . x . .
#   x . . x .
#   x . . . x
#
#   2. Moving on to the second row, place a queen at the first available column
#      and mark again:
#
#   Q x x x x
#   x x Q x x
#   x x x x x  <= no placement possible
#   x . x x x
#   x . . . x
#
#   3. Moving on to the third row, we see there is no available position,
#      meaning the placements of the queens in the previous two rows resulted
#      in a dead-end.  Backtrack and try the next possible column for row two
#      and mark again:
#
#   Q x x x x
#   x x x Q x
#   x . x x x
#   x x . x .
#   x . . . x
#
#   4. Moving to the third row again, we now have one column to try and we mark
#      again:
#
#   Q x x x x
#   x x x Q x
#   x Q x x x
#   x x x x .
#   x x x x x  <= no placement possible
#
#   5. We see that now the fifth row is totally blocked, meaning this is a
#      dead-end too.  Backtracking to row 3 yields no further possibilities,
#      so we backtrack to row 2 and try the next available position:
#
#   Q x x x x
#   x x x x Q
#   x . x x x
#   x . x x x
#   x x . . x
#
#   6.  Moving to row 3, where we only have once choice:
#
#   Q x x x x
#   x x x x Q
#   x Q x x x
#   x x x x x  <= no placement
#   x x x x x  <= possible
#
#   7.  Again no solution!  We now have to backtrack all the way to the first
#       row and rince and repeat.  Turns out there is no solution for N=5.
#
# To generate RDoc documentationm from this file:
#
# $ rdoc queens.rb


# This class represents a game board and contains methods for placing queens and
# marking squares as either blocked by a queen's line of sight or not.

class Board
  # The number of rows on the board.
  attr_reader :rows

  # The number of columns on the board.
  attr_reader :cols

  # Each square that has the possibility to place a queen at, has the value 0.
  Possible = 0

  # Initializes the game board by setting all squares to +Possible+.
  # +rows+:: the number of rows of the board
  # +cols+:: the number of columns of the board
  def initialize(rows, cols)
    @rows = rows
    @cols = cols
    @squares = Array.new(@rows) { Array.new(@cols, Possible) }
  end

  # Places a queen on the board.  It marks all the squares that are now blocked
  # by the queen.
  # +row+:: the row to place the queen at
  # +col+:: the column to place the queen at
  def place!(row, col)
    @squares[row][col] = :queen
    column!(row, col, method(:impossible!))
    row!(row, col, method(:impossible!))
    diagonals!(row, col, method(:impossible!))
  end

  # Removes a queen from a square of the board.  It unmarks all the squares that
  # were blocked by the queen.
  # +row+:: the square's row
  # +col+:: the square's column
  def remove!(row, col)
    column!(row, col, method(:possible!))
    row!(row, col, method(:possible!))
    diagonals!(row, col, method(:possible!))
    @squares[row][col] = Possible
  end

  # Marks a square as blocked by a queen's line of sight.  As the value of
  # +Possible+ (zero) represents an unblocked square, any other value would do,
  # but since we want to allow to roll back a single queen's line of sight, we
  # have to keep track of the number of lines of sight the square is blocked by.
  # +row+:: the square's row
  # +col+:: the square's column
  def impossible!(row, col)
    @squares[row][col] += 1
  end

  # Marks a square as being blocked by one less line of sight of a queen.
  # +row+:: the square's row
  # +col+:: the square's column
  def possible!(row, col)
    @squares[row][col] -= 1
  end

  # Returns whether it is possible to place a queen on a square on the board.
  # +row+:: the square's row
  # +col+:: the square's column
  def possible?(row, col)
    @squares[row][col] == Possible
  end

  # Marks an entire column on the board as blocked or not.
  # +row+:: the queen's row
  # +col+:: the queen's column
  # +m+:: either the method #possible! or #impossible!
  def column!(row, col, m)
    @rows.times { |r| m.call(r, col) unless r == row }
  end

  # Marks an entire row on the board as blocked or not.
  # +row+:: the queen's row
  # +col+:: the queen's column
  # +m+:: either the method #possible! or #impossible!
  def row!(row, col, m)
    @cols.times { |c| m.call(row, c) unless c == col }
  end

  # Marks the entire 45 and 135-degree diagonals on the board as blocked or not.
  # +row+:: the row of the queen
  # +col+:: the column of the queen
  # +m+:: either the method #possible! or #impossible!
  def diagonals!(row, col, m)
    (diagonals(row, col, +1, +1) - [[row, col]]).each { |r,c| m.call(r, c) }
    (diagonals(row, col, -1, +1) - [[row, col]]).each { |r,c| m.call(r, c) }
    extra_diagonals(row, col, m)
  end

  # Marks a diagonal passing through two queens on the board as blocked or
  # not.  It searches previous rows for queens and for each queen, given the
  # current queen's position, marks off the diagonal represented by those two
  # queens.  This prevents a future third queen from being placed in line with
  # these two.
  # +row+:: the row of the queen
  # +col+:: the column of the queen
  # +m+:: either the method #possible! or #impossible!
  def extra_diagonals(row, col, m)
    row.times do |r|
      c = @squares[r].find_index(:queen)
      dr = row - r
      dc = col - c
      diagonals(row, col, dr, dc).each do |rr,cc|
        m.call(rr, cc) unless @squares[rr][cc] == :queen
      end
    end
  end

  # Returns the diagonal crossing the square at +row+ and +col+ by coefficients
  # +dr+ and +dc+ (delta row and -column).
  # +row+:: the row of the square the diagonal passes through
  # +col+:: the column of the square the diagonal passes through
  # +dr+:: the delta row
  # +dc+:: the delta column
  def diagonals(row, col, dr, dc)
    n = [@rows, @cols].max - 1
    (-n..n).reduce([]) do |memo, i|
      r = row + i * dr
      c = col + i * dc
      memo << [r, c] if inside?(r, c)
      memo
    end.uniq
  end

  # Returns whether a square falls inside the board or not.
  # +row+:: the square's row
  # +column+:: the square's column
  def inside?(row, col)
    row >= 0 and row < @rows and col >= 0 and col < @cols
  end

  # Returns a string representation of the board, where a 'Q' represents a
  # queen and a '.' an empty square.
  def to_s
    @squares.reduce('') do |memo, row|
      memo + row.reduce('') do |memo, square|
        memo + case square
               when :queen then 'Q'
               else '.'
               end
      end + "\n"
    end
  end

  # Returns each queen's position as an array of columns, ordered by row.
  def to_a
    @squares.map { |row| row.find_index(:queen) }
  end
end


# This class solves the Queens Revisited problem for any game board.

class Solver

  # Creates an empty game board of a particular size.
  # +rows+:: the number of rows on the board
  # +cols+:: the number of columns on the board
  def initialize(rows, cols)
    @board = Board.new(rows, cols)
  end

  # Solves the Queens Revisited problem recursively by placing queens on
  # successive positions on the board, always one per row, and marking off which
  # squares are blocked by the lines of sight of the placed queens.  If it can
  # successfully place a queen in each row, it has found a solution.
  # +row+:: the row at which to begin placing queens
  # +block+:: a +Proc+ which is invoked with a solved board
  def solve(row, &block)
    if row == @board.rows
      yield @board
      return
    end

    @board.cols.times do |col|
      if @board.possible?(row, col)
        @board.place!(row, col)
        solve(row + 1, &block)
        @board.remove!(row, col)
      end
    end
  end
end


# Retrieves the sizes of the (square) board from the user and prints each
# solution to the Queens Revisited problem for a board of that size.  Each
# solution is printed as a list of queen columns, orderd by row, and as a
# visual board layout.
n = gets.to_i
Solver.new(n, n).solve(0) do |board|
  puts board.to_a.map { |c| c + 1 }.join(' ')
  puts board.to_s
  puts
end
