# WORK IN PROGRESS

class Solver

    Unexplored = "."
    Wall       = "#"
    Empty      = "-"
    Breadcrumb = "o"
    Exit       = "e"

    def initialize(state_file)
        if File.exist?(state_file)
            deserialize(state_file)
        else
            max_size    = 30
            @size       = 2 * max_size + 1
            @maze       = Array.new(@size) { Array.new(@size, Unexplored) }
            @row        = max_size
            @column     = max_size
            @state_file = state_file
        end
        Random.srand
    end

    def serialize
        File.open(@state_file, "w") do |io|
            io.puts @size
            @maze.each { |row| io.puts row.join }
        end
    end

    def deserialize(state_file)
        @state_file = state_file
        File.open(@state_file) do |io|
            @size = io.gets.chomp.to_i
            @maze = Array.new(@size) { io.gets.chomp.chars }
        end
        @row    = @size / 2
        @column = @size / 2
    end

    def look_at!(view)
        remember!(view)
        debug
    end

    def step!
        direction = take_step
        correct!(direction)
        direction
    end

    private

    def correct!(direction)
        degrees = case direction
                  when :up    then   0
                  when :down  then 180
                  when :right then 270
                  when :left  then  90
                  end
        rotate!(degrees)
        shift!
    end

    def rotate!(degrees)
        case degrees
        when 0
            # nothing to do
        when 90
            @maze = @maze.transpose.map(&:reverse)
        when 180
            @maze = @maze.map(&:reverse).reverse
        when 270
            @maze = @maze.map(&:reverse).transpose
        end
    end

    def shift!
        @maze = @maze.unshift((Unexplored * @size).chars)[0 .. -2]
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
            debug
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
        when :up    then [@row - 1, @column]
        when :down  then [@row + 1, @column]
        when :left  then [@row, @column - 1]
        when :right then [@row, @column + 1]
        end
    end

    def at(row, column)
        @maze[row][column]
    end

    def debug
        STDERR.puts Time.now
        @maze.each_index do |index|
            row = @maze[index]
            if index == @row
                STDERR.print row.join[0 .. @column - 1]
                STDERR.print "b"
                STDERR.puts row.join[@column + 1 .. -1]
            else
                STDERR.puts row.join
            end
        end
        STDERR.flush
    end
end

# ------------------------------------------------------------------------------
#  M a i n   P r o g r a m
# ------------------------------------------------------------------------------

Direction = { up: 'UP', down: 'DOWN', right: 'RIGHT', left: 'LEFT' }

solver = Solver.new("state.txt")
gets  # ignore player ID
view = 3.times.collect { gets.chomp.chars }
solver.look_at!(view)
puts Direction[solver.step!]
solver.serialize
