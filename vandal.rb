require 'httparty'

class Vandal

  attr_accessor :lang, :tag, :output_dir

  def initialize(options = {})
    @lang = options[:lang] || defaults[:lang]
    @tag = options[:tag] || defaults[:tag]
    @output_dir = options[:oyput_dir] || defaults[:output_dir]
  end

  def read_from_wikipedia(terms_map = {})
    terms_map.each_pair do |key, term|
      puts "Searching data for #{term}"
      filename = File.join(@output_dir, "#{key}.txt")
      File.open(filename, "w") do |f|
        data = HTTParty.get(wikipedia_url(term)).parsed_response

        data["query"]["pages"].first[1]["revisions"].each do |revision|

          diff_response = HTTParty.get(diff_url(revision['revid'], revision['parentid'])).parsed_response

          diff = diff_response["compare"]["*"]

          matches = diff.scan(fragment_match)
          if matches
            valid_matches = select_valid_matches(matches.flatten(&:strip)).compact
            f.write valid_matches * "\n"
          end
        end

        puts "Created file: #{filename}"
      end
    end
  end

  private

  def wikipedia_url(term)
    URI.encode "https://#{@lang}.wikipedia.org/w/api.php?action=query&prop=revisions&rvtag=#{@tag}&rvlimit=300&rvprop=ids|tags|comment&titles=#{term}&format=json"
  end

  def diff_url(revision_id, parent_id)
    URI.encode "https://es.wikipedia.org/w/api.php?action=compare&torev=#{revision_id}&fromrev=#{parent_id}&prop=diff&format=json"
  end

  def fragment_match
    /diffchange-inline\">([^<>&\[\]]*)<\/ins>/
  end

  def select_valid_matches(strings)
    clean = strings.map { |x| x unless x.match /[|'{#-&%]/ }
    clean.compact.map { |x| x if x.match /[a-zA-Z]/ }
  end

  def defaults
    { lang: "es",
      tag: "posible vandalismo",
      output_dir: "data"
    }
  end

end