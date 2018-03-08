class SelectPageParser
  # def self.domains
  #   return [twitter.com]
  # end
  
  def self.parse(url)
    return SelectPageParser.select(url)
  end
  def self.select(url)
    #
    # Guard against localhost or 127.0.0.1 urls
    #
    return [] if url =~ /localhost/ || url =~ /127.0.0.1/
    
    return nil if url =~ /^https?\:\/\/w?w?w?\.?linkedin\.com\/in\/(.+)/
    
    possible_models = []

    page_models = MetaProgrammingCommon.page_models
    page_models.each do |page_model|
      page_model.url_patterns.each do |pattern|
        if url =~ /#{pattern}/
          possible_models << page_model
        end
      end
    end
    
    #sorting by length puts PageBlog at the front and then reversing it puts 
    # longer classnames first which means that the https:// match will fall to the end
    possible_models = possible_models.sort_by(&:length).reverse
    
    #possible_models.each do |
    #debugger
    # if possible_models.size == 1 && possible_models.first == PageMediumArticle
    #   # verify that it is actually medium
    #
    #   status, page = UrlCommon.get_page(url)
    #   if status == :ok
    #     if page.body =~ /medium\.com/
    #       #todo this needs to be come finer grained to handle this
    #       return possible_models.first
    #     else
    #       debugger
    #       possible_models.delete(PageMediumArticle)
    #     end
    #   end
    # elsif possible_models.size == 1
    #   return possible_models.first
    # end
    if possible_models.size == 1 
      return possible_models.first
    end
    
    if possible_models.include?(PageMediumArticle)
      if PageMediumArticle.is_medium_article?(url)
        return PageMediumArticle
      else
        possible_models.delete(PageMediumArticle)
      end
    end
    
    #debugger

    # now return the highest entropy match
    #debugger
    url = url.gsub(/ /,'%20')
    parts = URI.parse(url)
    path = parts.path
    path_parts = path.split("/")
    cleaned_path_parts = []
    #debugger
    path_parts.each do |path_part|
      if path_part.blank?
      else
        cleaned_path_parts << path_part
      end
    end
    
    # add rss feed test 
    #debugger
    if possible_models.size == 1 && path.blank? && possible_models.first == PageBlog
      feed_url = UrlCommon.discover_feed_url(url)
      return possible_models.first if feed_url
    end
    
    
    
    path_to_match = cleaned_path_parts[0]
    host_to_match = parts.host
    
    possible_hosts = []
    if host_to_match =~ /www\./
      possible_hosts << host_to_match
      host_no_www = host_to_match.sub(/www\./,'')
      possible_hosts << host_no_www
    else
      possible_hosts << host_to_match
      possible_hosts << "www.#{host_to_match}"
    end
    
    #
    possible_models.each do |page_model|
      page_model.url_patterns.each do |url_pattern|
        puts "0 -- #{url_pattern} -- #{path_to_match}"
        next if path_to_match.nil?
        return page_model if url_pattern.to_s.include?(path_to_match)
      end
    end
    

    possible_models.each do |page_model|
      page_model.url_patterns.each do |url_pattern|
        #puts "1"
        #debugger
        return page_model if url_pattern.to_s.include?(host_to_match.gsub(/\./,"\\."))

        possible_hosts.each do |host_to_match|
          #puts "2"
          #debugger
          return page_model if url_pattern.to_s.include?(host_to_match.gsub(/\./,"\\."))
        end

        #return page_model if url_pattern =~ host_to_match
      end

    end
    
    if possible_models.size > 1
      possible_models.each do |possible_model|        
        return possible_model unless possible_model == PageMediumArticle
        return possible_model unless possible_model == PageBlog
      end
    end
    
  end
  #alias :parse, :select
end
