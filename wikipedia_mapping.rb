require "yaml"

class WikipediaMapping

  attr_reader :mapping

  def initialize(filename)
    raise "Non existent file with mapping for Wikpedia terms" unless File.exist?(filename)
    @filename = filename
    @mapping = YAML.load_file(filename)
  end

  def wikipedia_page_for(term)
    if @mapping[term].nil?
      raise "Could not find Wikipedia page mapping for #{term} in #{@filename}"
    else
      @mapping[term]
    end
  end

end

