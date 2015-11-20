class Histogram

    def initialize
        @luminances = Array.new(256, 0)
    end

    def read_image(io)
        while line = io.gets
            pixels = line.chomp.split
            pixels.each do |pixel|
                blue, green, red = pixel.split(',').map { |s| s.to_i }
                luminance = (0.2126 * red + 0.7152 * green + 0.0722 * blue).round
                @luminances[luminance] += 1
            end
        end
    end

    def exposure
        if midpoint < 256 / 3
            'night'
        else
            'day'
        end
    end

    private

    def midpoint
        total = @luminances.reduce(:+)
        midpoint = 0
        midpoint_total = 0
        while midpoint_total < total / 2
            midpoint_total += @luminances[midpoint]
            midpoint += 1
        end
        midpoint
    end
end

h = Histogram.new
h.read_image(STDIN)
puts h.exposure
