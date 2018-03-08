#encoding: utf-8
class DomainCountry < ApplicationRecord
  
  #########################################################################
  #
  # class level directives
  #
  #########################################################################

  #########################################################################
  #
  # attr_accessible / attr_accessor / attr_reader / attr_writer
  #
  #########################################################################

  #########################################################################
  #
  # validations
  #
  #########################################################################

  validates :domain, uniqueness: { scope: :country }
  validates_presence_of :domain, :country, :percentage

  #########################################################################
  #
  # belongs_to
  #
  #########################################################################

  #########################################################################
  #
  # has_many
  #
  #########################################################################


  #########################################################################
  #
  # call backs
  #
  #########################################################################


  #########################################################################
  #
  # scopes
  #
  #########################################################################


  #########################################################################
  #
  # CLASS METHODS
  #
  #########################################################################
  
  
  # DomainCountry.update_or_create("United States", "vice.com", 42.7)
  def self.add_audience_data(country, domain, percentage)
    domain_country = DomainCountry.new(country: country, domain: domain, percentage: percentage)
    if domain_country.save
    else
      puts "Error hit: #{domain_country.errors.full_messages}"
    end
    
    domain_country
  end
  
  #
  # Initial version of the create routine I wrote before I saw the explicit 
  # destroy requirement; left in place to illustrate a different approach (using .touch)
  #
  def self.update_or_create(country, domain, percentage)
    domain_country = DomainCountry.where(country: country, domain: domain).first
    
    # if we have it and the %age is the same then don't write the record again
    # or store the value again; just touch the record so that timestamp is updated
    # cheaper than a full write and lets us know that we did this today already
    if domain_country && domain_country.percentage == percentage
      domain_country.touch
    else
      domain_country = DomainCountry.new(country: country, domain: domain, percentage: percentage)
      if domain_country.save
      else
        puts "Error hit: #{domain_country.errors.full_messages}"
      end
    end
    
    domain_country
  end
  
  def self.delete_for_domain(domain)
    DomainCountry.where(domain: domain).destroy_all
  end



  #########################################################################
  #
  # INSTANCE METHODS
  #
  #########################################################################


  #########################################################################
  #
  # PRIVATE METHODS
  #
  #########################################################################

  private

  #########################################################################
  #
  # PROTECTED METHODS
  #
  #########################################################################

  protected
end
