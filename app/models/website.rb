#encoding: utf-8
class Website < ApplicationRecord
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

  #validates_uniqueness_of
  validates_presence_of :domain, :num_external_links, :num_internal_links

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
  
  #
  # Note -- since this has a unique constraint on domain have to treat it
  # as a find_or_update style action
  #
  def self.add_link_counts(domain, internal, external)
    website = Website.where(domain: domain).first
    
    #
    # Update existing and return 
    #
    if website
      website.update_attributes(domain: domain, num_internal_links: internal, num_external_links: external)
      return website
    end
    
    #
    # Create new and return
    #
    website = Website.new(domain: domain, num_internal_links: internal, num_external_links: external)
    if website.save
    else
      puts "Error hit: #{website.errors.full_messages}"
    end
    website
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
