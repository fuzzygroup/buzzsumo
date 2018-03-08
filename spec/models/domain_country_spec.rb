require 'rails_helper'

RSpec.describe DomainCountry, type: :model do
  describe ".delete_for_domain" do 
    it "should delete all records" do 
      dc = DomainCountry.create(country: "United States", domain: "vice.com", percentage: 42.7)
      expect{DomainCountry.delete_for_domain("vice.com")}.to change{DomainCountry.count}.from(1).to(0)
    end
  end
  
  describe ".add_audience_data" do 
    it "should add audience_data" do 
      expect{DomainCountry.add_audience_data("United States", "vice.com", 42.7)}.to change{DomainCountry.count}.from(0).to(1)
    end
  end
end
