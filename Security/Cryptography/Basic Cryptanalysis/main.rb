class String
  # Returns all characters in the string.
  def chars
    self.split(//)
  end
end

class Solver
  # Reads in the dictionary of valid words.
  def initialize
    @dict = read_dict('dictionary.lst')
  end

  # Analyses a ciphertext and attempts to find the one substitution that will
  # decode it into plaintext that is readable according to the dictionary of
  # allowed words. Returns nil if no solution could be found.
  def analyse(ciphertext)
    words = ciphertext.chomp.split
    solutions = solve(words, {})
    case solutions.count
    when 1
      words.map { |word| decode(word, solutions.first) }.join(' ')
    else
      nil
    end
  end

  private

  # Decodes a word of ciphertext given a found solution.
  def decode(word, solution)
    word.chars.map { |char| solution[char] }.join
  end

  # Finds all solutions for words of ciphertext, compatible with a starting
  # solution.
  def solve(words, solution)
    return [solution] if words.empty?
    word = words.first.downcase
    remaining = words[1..-1]
    solutions = @dict[word.length].flat_map do |candidate|
      find_solution(solution, word, candidate)
    end.compact.uniq
    solutions.flat_map { |solution| solve(remaining, solution) }
  end

  # Returns a character mapping from word to candidate, compatible with an
  # existing solution. Returns nil if no compatible mapping could be found.
  def find_solution(solution, word, candidate)
    mapping = {}
    word.chars.zip(candidate.chars) do |a, b|
      return nil if solution.key?(a) and solution[a] != b
      return nil if mapping.key?(a) and mapping[a] != b
      mapping[a] = b
    end
    solution.merge(mapping)
  end

  # Reads a dictionary file and returns a map where all words of the same
  # length are collected under the same key, the word length.
  def read_dict(filename)
    File.open(filename).readlines.reduce({}) do |memo, line|
      word = line.chomp.downcase
      (memo[word.length] ||= []) << word
      memo
    end
  end
end

ciphertext = readline
puts Solver.new.analyse(ciphertext)
