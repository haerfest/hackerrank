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

class Board
  attr_reader :rows, :cols

  Possible = 0

  def initialize(rows, cols)
    @rows = rows
    @cols = cols
    @squares = Array.new(@rows) { Array.new(@cols, Possible) }
  end

  def place!(row, col)
    @squares[row][col] = :queen
    column!(row, col, method(:impossible!))
    row!(row, col, method(:impossible!))
    diagonals!(row, col, method(:impossible!))
  end

  def remove!(row, col)
    column!(row, col, method(:possible!))
    row!(row, col, method(:possible!))
    diagonals!(row, col, method(:possible!))
    @squares[row][col] = Possible
  end

  def impossible!(row, col)
    @squares[row][col] += 1
  end

  def possible!(row, col)
    @squares[row][col] -= 1
  end

  def possible?(row, col)
    @squares[row][col] == Possible
  end

  def column!(row, col, m)
    @rows.times { |r| m.call(r, col) unless r == row }
  end

  def row!(row, col, m)
    @cols.times { |c| m.call(row, c) unless c == col }
  end

  def diagonals!(row, col, m)
    (diagonals(row, col, +1, +1) - [[row, col]]).each { |r,c| m.call(r, c) }
    (diagonals(row, col, -1, +1) - [[row, col]]).each { |r,c| m.call(r, c) }
    extra_diagonals(row, col, m)
  end

  def diagonals(row, col, dr, dc)
    n = [@rows, @cols].max - 1
    (-n..n).reduce([]) do |memo, i|
      r = row + i * dr
      c = col + i * dc
      memo << [r, c] if inside?(r, c)
      memo
    end.uniq
  end

  def inside?(row, col)
    row >= 0 and row < @rows and col >= 0 and col < @cols
  end

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

  def to_a
    @squares.map { |row| row.find_index(:queen) }
  end
end

class Solver
  def solve(board, row, &block)
    if row == board.rows
      yield board
      return
    end

    board.cols.times do |col|
      if board.possible?(row, col)
        board.place!(row, col)
        solve(board, row+1, &block)
        board.remove!(row, col)
      end
    end
  end
end

n = gets.to_i
solver = Solver.new
solver.solve(Board.new(n, n), 0) do |board|
  puts board.to_a.map { |c| c + 1 }.join(' ')
  puts board.to_s
  puts
end
