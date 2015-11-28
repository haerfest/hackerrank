class Histogram:
    def __init__(self):
        self.luminances = [0] * 256

    def read_image(self):
        try:
            while True:
                pixels = input()
                for pixel in pixels.split():
                    blue, green, red = [int(c) for c in pixel.split(',')]
                    luminance = round(0.2126 * red + 0.7152 * green + 0.0722 * blue)
                    self.luminances[luminance] += 1
        except EOFError:
            pass

    def exposure(self):
        if self.midpoint() < 256 / 3:
            return 'night'
        else:
            return 'day'

    def midpoint(self):
        total = sum(self.luminances)
        midpoint = 0
        midpoint_total = 0
        while midpoint_total < total / 2:
            midpoint_total += self.luminances[midpoint]
            midpoint += 1
        return midpoint

if __name__ == '__main__':
    h = Histogram()
    h.read_image()
    print(h.exposure())
