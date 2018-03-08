require 'rails_helper'

RSpec.describe Website, type: :model do
  describe ".add_link_counts" do 
    it "should create a website object when the parameters are specified" do 
      expect{Website.add_link_counts("vice.com", 12, 1)}.to change{Website.count}.from(0).to(1)
    end
    
    it "should set the attributes to the right fields" do
      ws = Website.add_link_counts("vice.com", 12, 1)
      expect(ws.domain).to eq "vice.com"
      expect(ws.num_internal_links).to eq 12
      expect(ws.num_external_links).to eq 1
    end
  end
end
