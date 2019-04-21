require_relative "wikipedia_mapping"
require 'httparty'

class Vandal

  attr_accessor :lang, :tags, :output_dir, :term_mapping_file

  def initialize(options = {})
    @lang = options[:lang] || defaults[:lang]
    @tags = options[:tags] || defaults[:tags]
    @output_dir = options[:output_dir] || defaults[:output_dir]
    @term_mapping_file = options[:term_mapping_file] || defaults[:term_mapping_file]
  end

  def read_from_wikipedia(term)
    puts "Searching data for #{term}"
    filename = File.join(@output_dir, "#{term}.txt")
    File.open(filename, "w") do |f|
      @tags.each do |tag|

        data = HTTParty.get(wikipedia_url(wp_mapping.wikipedia_page_for(term), tag)).parsed_response

        data["query"]["pages"].first[1]["revisions"].each do |revision|

          diff_response = HTTParty.get(diff_url(revision['revid'], revision['parentid'])).parsed_response

          diff = diff_response["compare"]["*"]

          matches = diff.scan(fragment_match)
          if matches
            valid_matches = select_valid_matches(matches.flatten(&:strip)).compact
            f.write valid_matches * "\n"
          end
        end
      end
      puts "Created file: #{filename}"
    end
  end

  private

  def wikipedia_url(title, tag)
    URI.encode "https://#{@lang}.wikipedia.org/w/api.php?action=query&prop=revisions&rvtag=#{tag}&rvlimit=#{defaults[:limit]}&rvprop=ids|tags|comment&titles=#{title}&format=json"
  end

  def diff_url(revision_id, parent_id)
    URI.encode "https://es.wikipedia.org/w/api.php?action=compare&torev=#{revision_id}&fromrev=#{parent_id}&prop=diff&format=json"
  end

  def fragment_match
    /diffchange-inline\">([^<>&\[\]]*)<\/ins>/
  end

  def select_valid_matches(strings)
    clean = strings.map { |x| x unless x.match /[|'{}#-&%]/ }
    clean.compact.map { |x| x if x.match /[a-zA-Z]/ }
  end

  def wp_mapping
    @mapping ||= WikipediaMapping.new(@term_mapping_file)
  end

  def defaults
    {
      lang: "es",
      tags: ["posible vandalismo", "mw-rollback"],
      output_dir: "data",
      limit: 200,
      term_mapping_file: "wiki-terms.yml"
    }
  end

end