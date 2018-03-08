class ParserPageBase
  
  def self.results_type
    return "user" if self.to_s =~ /User/
    return "thing"
  end
  
  def self.length    
    return self.name.size
  end
  
  def self.user_agent
    nil
  end
  
  def self.url_type_and_url_fid(url)
    self.url_patterns.each do |url_pattern|
      if url =~ url_pattern
        result = []
        result << self.account_type 
        #debugger
        url_fid = url_pattern.match(url)
        if url_fid
          url_fid = url_fid[1] 
        end
        
        result << url_fid
        return result
      end
    end
    return [nil, nil]
  end
  
  def self.validate_url(url)
    self.url_patterns.each do |url_pattern|
      return true if url =~ url_pattern
    end
    return false
  end
  
  def self.test
    all_results = []
    self.test_urls.each do |test_url|
      page_parser = self
      ###puts "About to run #{page_parser.name} with url: #{test_url}"
      #results = page_parser.parse(test_url)
      results = page_parser.fetch(test_url)
      #results = pp.parse
      #debugger if test_url == "https://www.youtube.com/c/BretFisherITPro"
      #debugger if test_url == "https://www.udemy.com/user/nick-janetakis/"
      if page_parser.should_parse?(test_url)
        puts "  Success! -- the parser returns true for should_parse? with #{test_url}"
      else
        raise "Error: #{page_parser.account_type} returns false for #{test_url} so this is either a url problem or a regex problem"
      end
      if results.is_a?(Hash) && 
        results["metrics"].keys.size != 0 && 
        results["page_elements"].keys.size != 0 &&
        page_parser.category =~ /education/
        #debugger
        puts "  Success! -- there is a results['metrics'] hash and there are Metric Keys: a#{results['metrics'].keys} keys AND there are Page Element keys: #{results['page_elements'].keys} keys"
      elsif results.is_a?(Hash) && results["metrics"].keys.size != 0
        puts "  Success! -- there is a results['metrics'] hash and there are #{results['metrics'].keys} keys"
      elsif page_parser.account_type =~ /blog/
        puts "  Still working out how to test blog parser"
      elsif results.is_a?(Hash) && 
            results["metrics"].keys.size == 0 && 
            results["source_urls"].empty? && 
            self.allows_zero_source_urls == false
        puts "  Partial Success! -- there is a results['metrics'] hash but there are 0 keys within it AND allows_zero_source_urls is set to false"
        puts "    And there are NO source_urls"
        raise "  Examine this error"
      elsif results.is_a?(Hash) && results["metrics"].keys.size == 0 && results["source_urls"].empty? && self.allows_zero_source_urls == false
        puts "  Partial Success! -- there is a results['metrics'] hash but there are 0 keys within it AND allows_zero_source_urls is set to false"
        puts "    And there are NO source_urls"
        raise "  Examine this error"
      elsif results.first == :error && results.second.to_s =~ /^404/
        puts "  Hit network error on resource -- 404"
      else
        raise "Error -- result type should be a hash but is instead: #{results}" unless results.is_a?(Hash)
      end
      all_results << results
    end
    return all_results
  end
  
  def self.get_source_url(results, type_pattern)
    results["source_urls"].each do |url|
      if source_url =~ type_pattern
        return url
      end
    end
  end
  
  def self.is_real_content_type?(page)
    return true
  end
  
  def self.test?
    true
  end
  
  
  
  def self.parser_mechanism
    "class"
  end
  
  def self.service_name
    parts = self.account_name.split(" ")
    return parts[0..(parts.size - 2)].join(' ')
  end
  
  def self.allows_zero_source_urls
    false
  end
  
  def self.domain_required
    true
  end
  
  
  def self.fetch_mechanism
    "mechanize"
  end
  
  def self.should_parse?(url)
    self.url_patterns.each do |url_pattern|
      #puts url_pattern
      if url =~ url_pattern
        return true
      end
    end
    return false
  end
  
  def self.parse(url, return_type=:karma_hash, html_page_body = nil, additional_source_urls = false)
    @url = url
    @additional_source_urls = additional_source_urls
    
    use_caching = false
    use_caching = true
    cache_time = 1.hour
    
    status = nil; page = nil;

    # 
    # the html_page_body option isn't set so fetch over the network
    #
    if html_page_body.nil?
      #
      # Cache variables
      #
      use_cache = true
      cache_duration = 1.hour
      cache = ActiveSupport::Cache::MemoryStore.new(expires_in: cache_duration)
      #cache = ActiveSupport::Cache::FileStore.new(expires_in: cache_duration)
      
      if self.fetch_mechanism == "javascript"
        #
        cache_key = TextCommon.sha_it("javascript_page_fetcher__#{@url}")        
        html_page_body = nil
        html_page_body = cache.read(cache_key) if use_cache
        if html_page_body
          status = :ok
          page = UrlCommon.create_mechanize_page_from_html(url, html_page_body)
          html_page_body = nil # this is a big ass (200k to 500k) string so get rid of it immediately
        elsif html_page_body.nil?
          #status, page = JavaScriptPageFetcher.fetch(@url, true)
          status, page = JavaScriptPageFetcher.fetch(@url)
          return status, page if status == :error
          cache.write(cache_key, page.body, expires_in: cache_duration) if use_cache
        end
      else
        #debugger #curl/7.54.0
        cache_key = TextCommon.sha_it("mechanize_page_fetcher__#{@url}")        
        html_page_body = nil
        html_page_body = cache.read(cache_key) if use_cache
        if html_page_body
          status = :ok
          page = UrlCommon.create_mechanize_page_from_html(url, html_page_body)
          html_page_body = nil # this is a big ass (200k to 500k) string so get rid of it immediately
        elsif html_page_body.nil?
          #debugger
          status, page = UrlCommon.get_page(@url, false, self.user_agent)
          return status, page if status == :error
          cache.write(cache_key, page.body, expires_in: cache_duration) if use_cache
        end
      end
    else
      #
      # No caching at all here; data comes in from an alternate path (memoize / reuse previous operation)
      #
      status = :ok
      page = UrlCommon.create_mechanize_page_from_html(url, html_page_body)
    end
    
    #
    # Convert it back to a string
    #
    # if page && page.is_a?(String)
    #   page = UrlCommon.create_mechanize_page_from_html(@url, page)
    # end
    
    
    
    results = MetricCommon.make_results_hash
    results["url"] = @url
    results["url_base"] = UrlCommon.url_base(@url)
    results["parser_type"] = self.account_type
    url_type, url_fid = self.url_type_and_url_fid(url)
    results["url_type"] = url_type
    results["url_fid"] = url_fid
    #debugger
    results["name"] = page.try(:title).try(:strip).try(:squish)
    
    return results unless status == :ok
    
    #debugger
    is_actual_content_type = self.is_real_content_type?(page)
    return results   if is_actual_content_type == false

    # if return_type == :karma_hash
    #
    #   debugger
    # end

    results = self.parse_as_html(page, results)
    results = self.parse_as_nokogiri(page, results)
    results = self.parse_for_page_elements(page, results)
    results["results_type"] = self.results_type

    return results
  end
  
  class <<self  
    alias_method :fetch, :parse
  end 
  
  def self.parse_for_page_elements(page, results)
    return results
  end

  
  def self.skip_home_page_extraction?
    false
  end
  
  
  def self.should_extract_from_home_page?(url)

    url_matches_against_normal_patterns = false
    
    # step 1 - make sure that the url matches against the normal patterns    
    self.url_patterns.each do |url_pattern|
      if url =~ url_pattern
        url_matches_against_normal_patterns = true
        break
      end
    end
    #puts "after block 1"
    #debugger
    
    # step 2 - if it matches against the normal then it has to be checked against the negated
    if self.respond_to?(:negated_url_patterns)
      skip = false
      self.negated_url_patterns.each do |negated_url_pattern|
        if url =~ negated_url_pattern
          skip = true
          break
        end
      end
      #puts "after block 2"
      #debugger
      return false if skip == true && url_matches_against_normal_patterns
      return true if url_matches_against_normal_patterns
      return false 
    else
      return true if url_matches_against_normal_patterns
      return false 
    end
  end
  
  def self.should_extract_from_home_page__?(url)
    skip = false
    if self.respond_to?(:negated_url_patterns)
      self.negated_url_patterns.each do |negated_url_pattern|
        if url =~ negated_url_pattern
          skip = true
        else
        end 
      end
      return false if skip
      return true
    else
      return true
    end
  end
  
  
  
end