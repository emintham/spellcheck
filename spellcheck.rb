# based on http://norvig.com/spell-correct.html

require 'set'

class SpellCheck
  attr_reader :bag_of_words

  def initialize
    @bag_of_words = Hash.new(1)
  end

  def parse_corpus(corpus)
    return unless File.exist?(corpus)
    f = File.open(corpus)
    f.each_line do |line|
      tokens = line.chomp.downcase.split(' ')

      tokens.each do |token|
        @bag_of_words[token] += 1
      end
    end
    f.close
    'Finished parsing.'
  end 

  def parse_unigrams(corpus)
    return unless File.exist?(corpus)
    f = File.open(corpus)
    f.each_line do |line|
      word_freq = line.chomp.downcase.split(' ')
      @bag_of_words[word_freq[0]] = word_freq[1].to_i
    end
    f.close
    'Finished parsing.'
  end

  def deletion(word)
    deleted_set = Set.new
    0.upto(word.length - 1) do |index|
      new_word = word.dup
      new_word[index] = ''
      deleted_set << new_word
    end
    deleted_set
  end

  def insertion(word)
    inserted_set = Set.new
    0.upto(word.length) do |index|
      ('a'..'z').each do |char|
        new_word = word.dup
        new_word.insert(index, char)
        inserted_set << new_word
      end
    end
    inserted_set
  end

  def substitution(word)
    substituted_set = Set.new
    0.upto(word.length - 1) do |index|
      ('a'..'z').each do |char|
        new_word = word.dup
        new_word[index] = char unless char == new_word[index]
        substituted_set << new_word
      end
    end
    substituted_set
  end

  def transposition(word)
    transposed_set = Set.new
    0.upto(word.length - 2) do |index|
      new_word = word.dup
      new_word[index], new_word[index + 1] = new_word[index + 1], new_word[index]
      transposed_set << new_word
    end
    transposed_set
  end

  def edit_distance_one_set(word)
    case word
    when Set
      final_set = Set.new
      final_set.each do |w|
        final_set << edit_distance_one_set(w)
      end
      final_set
    when String
      deletion(word) | insertion(word) | substitution(word) | transposition(word) 
    end
  end

  def in_bag?(word)
    @bag_of_words.key? word
  end

  def candidates(word)
    Enumerator.new do |enum|
      one_set = edit_distance_one_set(word)
      one_set.each do |w|
        enum << w if in_bag?(w)
      end

      edit_distance_one_set(one_set).each do |w|
        enum << w if in_bag?(w)
      end

      enum << word
    end
  end

  def correct(word)
    return word if in_bag? word
    most_likely = word
    likelihood = 0
    candidates(word).each do |w|
      next unless @bag_of_words[w] > likelihood
      most_likely = w
      likelihood = @bag_of_words[w]
    end
    most_likely
  end
end