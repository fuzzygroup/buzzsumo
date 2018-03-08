#encoding: UTF-8
class UrlCommon 
  
  #require 'feedbag'
  
  # UrlCommon.is_valid?("http://fuzzyblog.io/blog/")
  def self.is_valid?(url)
    begin
      #parts = URI.parse(url)
      #return true
      
      result = Fuzzyurl.from_string(url)
      # {
      #     :protocol => "https",
      #     :username => nil,
      #     :password => nil,
      #     :hostname => "api.example.com",
      #         :port => nil,
      #         :path => "/users/123",
      #        :query => "full=true",
      #     :fragment => nil
      # }
     # debugger
      return false if result.hostname.nil?
      return false if result.protocol.nil?
      return false if (!result.hostname.include?('.')) && result.protocol.nil?
      return true
    rescue StandardError => e
      return false
    end
  end
  
  def self.get_base_domain(url)
    #debugger if url =~ /c06rh22whx1g/
    begin
      url = url.gsub(/ /,'%20')
      parts = URI.parse(url)
      return parts.host.gsub(/^www./,'')
    rescue StandardError => e
      fu = Fuzzyurl.from_string(url)
      return fu.hostname.gsub(/^www./,'')
    end
  end
  
  # 
  def self.mpage_is_html?(page)
    return true if page.respond_to?(:title)
    return false
  end
  
  def self.join0(base, rest, debug = false)
    puts "base = #{base}" if debug
    puts "rest = #{rest}" if debug
    return "#{base}/#{rest}" unless base.last == '/'
    return "#{base}#{rest}"
    #return "#{base.sub(/\/$/,'')}#{rest}"
  end

  def self.join(base, rest, debug = false)
    #fuzzy_parts = Fuzzyurl.new(base)
    
    return URI.join(base, rest).to_s
    
    #return URI.join
    
    puts "base = #{base}" if debug
    puts "rest = #{rest}" if debug
    return "#{base}/#{rest}" unless base.last == '/'
    return "#{base}#{rest}"
    #return "#{base.sub(/\/$/,'')}#{rest}"
  end

  
 def self.url_no_www(url)
   parts = Fuzzyurl.new(url)
   return parts.hostname.sub(/^www\./, '') + parts.path + '?' + parts.query if parts.query
   return parts.hostname.sub(/^www\./, '') + parts.path
 end
 
 
 #
 # This is designed to count the number of internal / external links
 # for a relative link, one without a host i.e /about/, this is easy
 # but for a fully qualified link, you have to compare to the base_domain
 # of the url you are testing otherwise you would have about.vice.com 
 # being recorded as an external link 
 #
 # UrlCommon.count_internal_and_external_links(http://www.vice.com)
 def self.count_internal_and_external_links(url)
   #
   # Get the base domain of what we're comparing to
   #
   base_domain = UrlCommon.get_base_domain(url)
   
   #
   # This handles the underlying page_fetch
   #
   status, page = UrlCommon.get_page(url)
   return unless status == :ok
   
   link_counts = {internal: 0, external: 0}

   links = page.links
   
   links.each do |link|
     if link.uri.host.nil?
       link_counts[:internal] += 1
     elsif UrlCommon.get_base_domain(link.uri.to_s) == base_domain
       link_counts[:internal] += 1
     else
       link_counts[:external] += 1
     end
   end
   link_counts
 end
 
 def self.count_links(html)
   if html =~ /<html/i
     content_type = "html"
   else
     content_type = "ascii"
   end
   parts = html.split(" ")
   link_ctr = 0
   parts.each do |part|
     link_ctr = link_ctr + 1 if part =~ /https:?\/\// && content_type == 'ascii'
     link_ctr = link_ctr + 1 if part =~ /<a [^>]+.+<\/a>/i && content_type == 'html'
   end
   link_ctr
 end
 
  #tested #https://www.amazon.com/gp/product/B01DT4A2R4/ref=as_li_qf_sp_asin_il_tl?ie=UTF8&tag=nickjanetakis-20&camp=1789&creative=9325&linkCode=as2&creativeASIN=B01DT4A2R4&linkId=496be5e222b6291369c0a393c797c2c0
  # returns nil if link isn't amazon at all
  # returns true if link is amazon and has referrer code
  # returns false if link is amazon and doesn't have referrer code
  def self.check_for_amazon_referrer(url, referrer_code)
    #https://github.com/gamache/fuzzyurl.rb
    fu = Fuzzyurl.from_string(url)
    return nil if fu.hostname.nil? 
    base_domain = fu.hostname.sub(/^www./,'')
    # base_domain = UrlCommon.get_base_domain
    parts = base_domain.split(".")
    return nil if parts[0] != "amazon"
    #referer_code = self.account.user.details[:amazon_referrer_code]
    if url =~ /#{referrer_code}/
      return true
    else
      return false
    end
  end
  
  #def self.check_for_jekyll_subdomain?(url)
  def self.has_own_domain?(url)
    return false if url =~ /\.github\.io/
    return false if url =~ /\.blogspot\.com/
    return false if url =~ /\.wordpress\.com/
    #return false if url =~ /\..+\./
    return true
    if site_url =~ /\..+\./
      return true
    else
      analysis_results << "You have a domain of your own; that's a great first step!"
    end
    
  end
  
  def self.agent
    return Mechanize.new
  end
  
  def self.get_page(url, return_html = false, user_agent = nil)
    agent = Mechanize.new { |a| 
      if user_agent.nil?
        a.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:46.0) Gecko/20100101 Firefox/46.0"
      else
        a.user_agent = user_agent
      end
      #a.user_agent = "curl/7.54.0"
      #debugger
    }
    agent.verify_callback = Proc.new do |ok,x509|
      status = x509.error
      msg = x509.error_string
      logger.warn "server certificate verify: status: #{status}, msg: #{msg}" if status != 0
      true # this has the side effect of ignoring errors. nice!
    end 
    begin
      page = agent.get(url)
      if return_html
        return :ok, page.body
      else
        return :ok, page
      end
      #return :ok, page
    rescue StandardError => e
      return :error, e
    end
  end
  
  # def self.get_page_caching_attempt(url, return_html = false)
  #   agent = Mechanize.new { |a|
  #     a.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:46.0) Gecko/20100101 Firefox/46.0"
  #   }
  #   agent.verify_callback = Proc.new do |ok,x509|
  #     status = x509.error
  #     msg = x509.error_string
  #     logger.warn "server certificate verify: status: #{status}, msg: #{msg}" if status != 0
  #     true # this has the side effect of ignoring errors. nice!
  #   end
  #   begin
  #     page = agent.get(url)
  #     if return_html
  #       Rails.cache.fetch(UrlCommon.sha_it(url), :expires_in => 1.hour) do
  #         page.body
  #       end
  #       # Rails.cache.fetch(UrlCommon.sha_it(url), :expires_in => 1.hour) do
  #       #   debugger
  #       #   page.body
  #       # end
  #       return :ok, page.body
  #     else
  #       return :ok, page
  #     end
  #   rescue StandardError => e
  #     return :error, e
  #   end
  # end
  
  
  def self.check_for_404(url, elixir_style = false)
    agent = Mechanize.new
    results = []
    
    begin
      head_result = agent.head(url)
      return OpenStruct.new(:url => url, :status => 200) if elixir_style == false
      return :ok, url if elixir_style
    rescue StandardError => e
      if e.to_s =~ /404/
        return OpenStruct.new(:url => url, :error => e, :status => 404)
      else
        return OpenStruct.new(:url => url, :error => e, :status => 404)        
      end
    end
  end
  
  def self.check_for_broken_links(links)
    results = []
    agent = Mechanize.new
    links.each do |link|
      begin
        result = agent.head(link.href)
        results << OpenStruct.new(:url => link.href, :status => 200)
      rescue StandardError => e
        if e.to_s =~ /404/
          results << OpenStruct.new(:url => link.href, :error => e, :status => 404)
        end
      end
    end
    #debugger
    results
  end
  
  # def self.parse_html_for_rssurl_from_head(site_url, page = nil, debug = false)
  # end
  
  def self.select_best_rssurl_from_rssurls(urls)
    return urls.sort_by(&:length).first
  end
  
  def self.parse_html_for_rssurl_from_head(site_url, page = nil, debug = false)
    if page
      status = :ok
    else
      status, page = UrlCommon.get_page(site_url)
    end
    puts "Into html parse for rssurl" if debug
    possibles = []
    if status == :ok && page
      #results = page.css("link[rel='alternate']")
      results = page.css("link[rel='alternate'][type='application/rss+xml']")
      #
      # If only a single one then return it
      #
      #return results.first['href'] if results.first['type'] =~ /application\/rss\+xml/i && results.size == 1
      return results.first['href'] if results.size == 1
      
      #
      # If an array then filter out the comments
      #
      results.each do |result|
        possibles << result unless result['title'] =~ /comments? feed/i
      end
      
      #
      # Loop over the possibles and just return the shortest url
      #
      # Todo -- can likely do a better job on this
      #
      urls = []
      possibles.each do |possible|
        urls << possible['href']
      end
      return UrlCommon.select_best_rssurl_from_rssurls(urls)
      #return urls.sort_by(&:length).first
      
      
      # results.each do |result|
      #
      #   end
      # end
      # doc = Nokogiri::HTML(page.body)
      # results << doc.at('link[rel="alternate"]')
      # results = results.flatten
    end
  end
  
  # fucking idiotic test case for this fucking idiot is: https://devslopes.com/
  def self.test_random_url(url_or_host)
    random_filename = TextCommon.sha(Time.now.to_s) + ".xml"
    if url_or_host =~ /http/
      url = File.join(url_or_host, random_filename)
    else
      url = File.join("http://", host, random_filename)      
    end
    status, url = UrlCommon.check_for_404(url, true)   
    #
    # Key bit of logic -- if we get a return value for a randomized sha then that means that
    # a) the destination site owner is a fucking moron
    # b) that the destination site owner has set his site so it NEVER returns a 404
    # c) they're a fucking moron
    # d) if I get a 200 back then it means that they return you to the home page for anything and NOT
    #    a proper 404 so need to flip flop the logic and return error on a 200; sheesh
    #
    return :error, url if status == :ok
    return :ok, url
  end
  
  def self.possible_rssurls(site_url, skip_slash_blog = false)
    # urls we will probe
    possible_rssurl_formats = []

    # normal baselines
    possible_rssurl_formats << "feed.xml"
    possible_rssurl_formats << "rss.xml"
    possible_rssurl_formats << "atom.xml"
    possible_rssurl_formats << "feed/"
    
    # optionally look at /blog/
    possible_rssurl_formats << "/blog/feed.xml"
    possible_rssurl_formats << "/blog/rss.xml" 
    possible_rssurl_formats << "/blog/atom.xml" 
    possible_rssurl_formats << "/blog/feed/" 
    
    possible_rssurls = []
    possible_rssurl_formats.each do |url_format|
      possible_rssurls << UrlCommon.join(site_url, url_format)      
    end
    
    return  possible_rssurls
  end
  
  #https://500hats.com/feed
  # UrlCommon.discover_feed_url("https://nickjanetakis.com")  
  def self.discover_feed_url(site_url, debug = false)
    # step 1: remove the file from the site_url if it has one
    # step 2: problem the common ones and 404 check
    
    #
    # Build a set of possibles
    #
    possible_rssurls = UrlCommon.possible_rssurls(site_url)
    
    #
    # Keep track of failures
    #
    failed_probes = Set.new
    
    # step 3: parse the html
    #<link rel="alternate" type="application/rss+xml" href="http://scripting.com/rss.xml" />
    #<link rel="alternate" type="application/rss+xml" title="Matt Mullenweg &raquo; Feed" href="https://ma.tt/feed/" />
    #<link rel="alternate" type="application/rss+xml" title="Matt Mullenweg &raquo; Comments Feed" href="https://ma.tt/comments/feed/" />
    
    #
    # Stage 1 -- do http head probing
    #
    possible_rssurls.each do |rssurl|
      puts "Head Probing for: #{rssurl}" if debug
      
      # abort if we doubled blog i.e. /blog/blog/ in the url
      next if rssurl =~ /blog\/blog/
      next if failed_probes.include?(rssurl)
      
      status, url = UrlCommon.check_for_404(rssurl, true)    
      random_status, random_url = UrlCommon.test_random_url(site_url)
      #debugger 
      return rssurl if status == :ok && random_status == :ok
      failed_probes << rssurl
    end
    
    puts "After probe, failed_probes as: #{failed_probes.inspect}"
    
    #
    # Stage 2-- if subdirectory go up one level and probe again
    #
    # TODO
    
    
    
    #
    # Stage 3 -- Goto root and probe again 
    #
    #test for this is the nick site
    fuzzy_url_parts = Fuzzyurl.new(site_url)
    base_url = "#{fuzzy_url_parts.protocol}://#{fuzzy_url_parts.hostname}"
    possible_rssurls = UrlCommon.possible_rssurls(base_url)
    #debugger
    possible_rssurls.each do |rssurl|
      puts "Head Probing for: #{rssurl} at site root stage" #if debug
      
      # abort if we doubled blog i.e. /blog/blog/ in the url
      next if rssurl =~ /blog\/blog/
      next if failed_probes.include?(rssurl)
      
      status, url = UrlCommon.check_for_404(rssurl, true)    
      return rssurl if status == :ok
      failed_probes << rssurl
    end
    
    
    #
    # Stage 4 - parse the html
    #
    rssurl = UrlCommon.parse_html_for_rssurl_from_head(site_url, nil, true)
    return rssurl if rssurl
    
    #
    # Stage 5 - fall over to feedback
    #
    results = Feedbag.find(site_url)
    # checked_results = []
    # results.each do |result|
    #   struct = UrlCommon.check_for_404(result)
    #   checked_results << result if struct.status == 200
    # end
    
    #
    # Stage 6 - cache failures to redis so don't look for them again
    #
    #$redis.
    
    return UrlCommon.select_best_rssurl_from_rssurls(results)
  end
  
=begin  
  base_url = "https://www.udemy.com/the-build-a-saas-app-with-flask-course/"
  partial_url = "/the-build-a-saas-app-with-flask-course/#instructor-16148498"
  UrlCommon.fix_relative_url(base_url, partial_url)
=end  
  
  def self.fix_relative_url(base_url, partial_url)
    return partial_url if partial_url =~ /^http/
    base_url = base_url.gsub(/ /,'%20')
    parts = URI.parse(base_url)
    return parts.scheme + '://' +  parts.host + partial_url
    return File.join(base_url, partial_url)
  end
  
  def self.create_mechanize_page_from_html(url, html)
    mechanize_page = Mechanize::Page.new(nil, {'content-type'=>'text/html'}, html, nil, Mechanize.new)
    url = url.gsub(/ /,'%20')
    mechanize_page.uri = URI.parse(url)    
    
    return mechanize_page
  end
  
  #
  # Returns a url w/o http://wwww 
  # UrlCommon.url_base("https://www.udemy.com/the-build-a-saas-app-with-flask-course/")
  # "udemy.com/the-build-a-saas-app-with-flask-course/"
  #
  def self.url_base(url, base_domain=nil)
    if base_domain.nil?
      base_domain = UrlCommon.get_base_domain(url)
    end
    begin
      url = url.gsub(/ /,'%20')      
      parts = URI.parse(url)
      extra = ""
      extra = "?#{parts.query}" if parts.query
      url_base = "#{base_domain}#{parts.path}#{extra}"
      return url_base[0..254]
    rescue StandardError => e
      fu = Fuzzyurl.from_string(url)
      base_domain = UrlCommon.get_base_domain(url)
      extra = ""
      extra = "?#{fu.query}" if fu.query
      url_base = "#{base_domain}#{fu.path}#{extra}"
      return url_base[0..254]
    end
  end
  
  # status, url = UrlCommon.validate_with_merge_fragment("nickjj/orats", "https://www.github.com/")
  def self.validate_with_merge_fragment(url, merge_fragment)
    #
    # verify it is a valid url and it isn't a 404 or redirect
    #
    if UrlCommon.is_valid?(url) && UrlCommon.check_for_404(url)
      return true, url 
    end
    
    #
    # Try and make it valid
    #
    if url =~ /^http/
      # if its invalid and has http then don't know what to do so return false
      return false, url
    end
    
    url = File.join(merge_fragment, url)
    if UrlCommon.is_valid?(url) && UrlCommon.check_for_404(url)
      return true, url
    end        
  end
  
  def self.get_protocol(url)
    parts = url.to_s.split(":")
    return parts.first
  end
  

  
end
