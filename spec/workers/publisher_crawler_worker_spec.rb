require 'rails_helper'
RSpec.describe PublisherCrawlerWorker, type: :worker do
  #
  # This that the DomainCountry objects are created
  #
  it "should fetch data and insert it into the database (DomainCountry)" do 
    expect{PublisherCrawlerWorker.new.perform("vice.com")}.to change{DomainCountry.count}.from(0).to(5)
  end
  
  it "should fetch data and insert it into the database (Website)" do 
    expect{PublisherCrawlerWorker.new.perform("vice.com")}.to change{Website.count}.from(0).to(1)
  end
  
end
