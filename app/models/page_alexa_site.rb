class PageAlexaSite < ParserPageBase
  
=begin
  Usage example: 
  
  results = PageAlexaSite.fetch("https://www.alexa.com/siteinfo/vice.com")
  
  and then look at results["audience_data"]
  
  -or-
  
  PageAlexaSite.test_urls.each do |test_url|
    results = PageAlexaSite.fetch(test_url)
    puts results["url"]
    puts results["audience_data"]
  end
=end
  
  def self.url_patterns
    #"https://weworkremotely.com/remote-jobs/search?utf8=%E2%9C%93&term=rails"
    [/^https?\:\/\/w?w?w?.?alexa\.com\/siteinfo\/(.+)/]
    
  end
  
  def self.test_url
    self.test_urls.first
  end
  
  def self.test_urls
    [
"https://www.alexa.com/siteinfo/vice.com",
"https://www.alexa.com/siteinfo/buzzfeed.com",
"https://www.alexa.com/siteinfo/cnn.com"
    ]
  end
  
  def self.account_name
    "Alexa Site Info"
  end
  
  def self.account_type
    "site_ranking"
  end

  def self.description
    ""
  end
  
  def self.category
    "site_metrics"
  end
  
  def self.available?
    true
  end
  
  def self.font_awesome_icon
    "fa-alexa"
  end

  def initialize(url)
    @url = url
  end

  def self.parse_as_html(page, results)
    return results
  end

  def self.parse_as_nokogiri(page, results)
    results["audience_data"] = []
    
    table_rows = page.parser.css("table#demographics_div_country_table").css("tbody").css("tr")
    
    table_rows.each do |table_row|
      audience = {}
      # structure we want; overkill to define it in advance for only 2 elements but makes it explicit 
      # which is a good practice for the future
      audience["country"] = nil
      audience["percentage"] = nil
      
      # NOTE this next line results in a country with a UTF-8 160 first character which .strip won't filter out 
      # since it is not really blank space; gsub doesn't work either (bizarrely) so just offset by first character
      # BAD solution for maintainability but right time bounding choice for a proof of concept demo app
      audience["country"] = table_row.css("td").css("a").first.text.gsub(/&nbsp;/,' ').strip[1..256]
      audience["percentage"] = table_row.css("td.text-right").first.text.strip.sub(/%/,'')
      
      results["audience_data"] << audience if audience["country"] && audience["percentage"]
    end
    return results

  end
end
  
  
=begin
  data example here

=end
