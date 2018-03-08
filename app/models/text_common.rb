class TextCommon 
  
  # Class Wide Dependencies
  
  require 'digest/sha1'
  
  def self.get_meta_description(url, html)
    page = UrlCommon.create_mechanize_page_from_html(url, html)
    description = ""
    begin
      description = page.parser.at("meta[name='description']")['content']
    rescue StandardError => e
    end
    return description 
  end
  
  def self.get_page_title(url, html)
    page = UrlCommon.create_mechanize_page_from_html(url, html)
    title = ""
    begin
      title = page.parser.css('title').first.content
    rescue StandardError => e
    end
    return title 
  end
  
  
  def self.sha(text)
    #return "" if text.nil?
    return Digest::SHA1.hexdigest(text.to_s)
  end
  
  # todo strip html and then count words
  # todo nick readability python sublime
  def self.count_words(text)
    parts = text.split(" ")
    return parts.size
  end
  
  
  
  def self.present_key(str)
    parts = str.split("_")
    str = parts.map(&:capitalize).join(' ')
    return str
  end
  
  def self.convert_k_to_number(text)
    if text =~ /k/i
      #2.9k
      parts = text.split(/k/i)
      return (parts[0].to_f*1000).round(0)
    elsif text =~ /m/i
      #2.9k
      parts = text.split(/m/i)
      return (parts[0].to_f*1000000).round(0)
    end
    return text
  end
  
  def self.strip_breaks(text)
    return text.gsub(/\n/,'').gsub(/\r/,'')
  end
  
  def self.sha_it(text)
    text = text.to_json if text.is_a?(Hash) || text.is_a?(Array)
    return Digest::SHA1.hexdigest(text.to_s)
  end
  
  def self.suggest_hash_tags(text)
  end
  
  def self.extract_links_from_text(text)
    agent = Mechanize.new
    html = "<HTML><BODY>#{text}</BODY></HTML>"
    page = Mechanize::Page.new(nil,{'content-type'=>'text/html'},html,nil,agent)
    return page.links
  end
  
  
  # return a true or false when a post is "NOTABLE" i.e. actually significant
  # look at gauging the economic amount / ECONOMIC VALUE of work that went into it: 
  #  * a lot of links are notable
  #  * a lof of words are notable
  #  * rich amounts of tag elements are notable
  #. * a short bit of content likely isn't
  # distinguish between a reblogged thing or a link blog item
  def self.is_notable?(text)
  end
  
  def self.summarize(text)
  end
  
  def self.create_hash_tags(text)
  end
  
  def self.create_category(text)
  end
end
