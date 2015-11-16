# WORK IN PROGRESS

class Solver

    Unexplored = " "
    Wall = "#"
    Empty = "-"
    Breadcrumb = "o"
    Exit = "e"

    Output = { up: 'UP', down: 'DOWN', right: 'RIGHT', left: 'LEFT' }

    def initialize(state_file)
        if File.exist?(state_file)
            deserialize(state_file)
        else
            max_size = 30
            @size = 2 * max_size + 1
            @maze = Array.new(@size) { Array.new(@size, Unexplored) }
            @row = max_size
            @column = max_size
            @direction = :up  # don't know, but doesn't matter
            @state_file = state_file
        end
        Random.srand
    end

    def serialize
        File.open(@state_file, "w") do |io|
            io.puts @row
            io.puts @column
            io.puts @direction
            io.puts @size
            @maze.each { |row| io.puts row.join }
        end
    end

    def deserialize(state_file)
        @state_file = state_file
        File.open(@state_file) do |io|
            @row = io.gets.chomp.to_i
            @column = io.gets.chomp.to_i
            @direction = io.gets.chomp.to_sym
            @size = io.gets.chomp.to_i
            @maze = Array.new(@size) { io.gets.chomp.chars }
        end
    end

    def look_at!(view)
        remember!(rotate(view))
        debug
    end

    def step!
        @direction = take_step
        puts Output[@direction]
        @row, @column = position(@direction)
    end

    private

    def rotate(view)
        case @direction
        when :up then view
        when :down then rotate_180(view)
        when :right then rotate_90(view)
        when :left then rotate_270(view)
        end
    end

    def rotate_180(view)
        view.map(&:reverse).reverse
    end

    def rotate_90(view)
        view.transpose.map(&:reverse)
    end

    def rotate_270(view)
        view.map(&:reverse).transpose
    end

    def remember!(view)
        radius = view.count / 2
        row = @row - radius
        view.each do |vrow|
            column = @column - radius
            vrow.each do |object|
                place!(object, row, column)
                column += 1
            end
            row += 1
        end
    end

    def place!(object, row, column)
        known = @maze[row][column]
        if known == Unexplored
            @maze[row][column] = object
        elsif known == Breadcrumb and object == Empty
            # keep breadcrumb
        elsif known != object
            raise "maze construction: cannot place #{object} over #{known} at (#{row},#{column})"
        end
    end

    def take_step
        begin
            direction = case Random.rand(4)
                        when 0 then :up
                        when 1 then :down
                        when 2 then :left
                        when 3 then :right
                        end
        end while at(*position(direction)) == Wall
        direction
    end

    def position(direction)
        case direction
        when :up then [@row - 1, @column]
        when :down then [@row + 1, @column]
        when :left then [@row, @column - 1]
        when :right then [@row, @column + 1]
        end
    end

    def at(row, column)
        @maze[row][column]
    end

    def debug
        direction = { up: '^', down: 'v', right: '>', left: '<' }
        @maze.each_index do |index|
            row = @maze[index]
            if index == @row
                STDERR.print row.join[0..@column-1]
                STDERR.print direction[@direction]
                STDERR.puts row.join[@column+1..-1]
            elsif row.any? { |object| object != Unexplored }
                STDERR.puts row.join
            end
        end
    end
end

solver = Solver.new("state.txt")
gets
view = 3.times.collect { gets.chomp.chars }
solver.look_at!(view)
solver.step!
solver.serialize
