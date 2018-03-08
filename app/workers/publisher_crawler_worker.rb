class PublisherCrawlerWorker
  include Sidekiq::Worker

  #
  # Example of how to call: PublisherCrawlerWorker.new.perform("vice.com")
  #
  def perform(domain)
    results = PageAlexaSite.fetch("https://www.alexa.com/siteinfo/#{domain}")
    puts "results['audience_data'] = #{results['audience_data']}" 

    #
    # Abort processing if we can't get the data 
    #
    return unless results["audience_data"].is_a?(Array)
    
    #
    # Clear out previous domain data
    #
    DomainCountry.delete_for_domain(domain)
    
    #
    # Iterate the audience_data
    #
    results["audience_data"].each_with_index do |audience, ctr|
      
      #
      # Only handle first 5 rows
      # 
      if ctr <= AUDIENCE_ROWS_TO_PROCESS
        DomainCountry.add_audience_data(audience["country"], domain, audience["percentage"])
      end
    end
    
    #
    # Handle link counts
    #
    link_counts = UrlCommon.count_internal_and_external_links("http://www.#{domain}")
    Website.add_link_counts(domain, link_counts[:internal], link_counts[:external])    
  end
end
