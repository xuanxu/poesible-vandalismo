require_relative 'vandal'

class Poet

  attr_accessor :data_dir

  def initialize(options = {})
    @data_dir = options[:data_dir] || defaults[:data_dir]
  end

  def poem(term)
    @term = term
    poem = []

    poem_size.times do
      candidate = aggregate_verses(verses.sample, [2,3,4,5].sample)
      candidate = candidate_not_too_long(candidate)

      poem << clean_verse(candidate)
    end

    poem = poem * "\n"
    poem
  end

  def verses
    @verses ||= read_data
  end

  private

  def read_data
    filename = File.join(@data_dir, "#{@term}.txt")
    Vandal.new(output_dir: @data_dir).read_from_wikipedia(@term) unless File.exist?(filename)
    data = File.read(filename).split
    if data.size < 1
      File.delete(filename)
      raise "The #{filename} file is empty or do not exist"
    end
    data
  end

  def poem_size
    (3..[14, verses.size].min).to_a.sample
  end

  def aggregate_verses(verse, size)
    if verse.strip.split.size < size
      verse = [verse, verses.sample] * " "
      verse = aggregate_verses(verse, size)
    end

    verse
  end

  def candidate_not_too_long(verse)
    limit = max_words_for_verse
    verse_words = verse.strip.split.map(&:strip)
    if verse_words.size > limit
      difference = verse_words.size - limit
      verse = verse_words.slice((0..difference).to_a.sample, limit)
    end

    verse
  end

  def max_words_for_verse
    [6,7,8,9].sample
  end

  def clean_verse(verse)
    verse.strip.delete("-=/&%$|@#[]{}*").split.map(&:strip).join(" ")
  end

  def defaults
    {
      data_dir: "data"
    }
  end

end