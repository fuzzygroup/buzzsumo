class MetricCommon 
  
  # results = MetricCommon.make_results_hash
  def self.make_results_hash
    results = {}
    results["metrics"] = {}
    results["posts"] = []
    results["source_urls"] = []
    results["url"] = ""
    results["parser_type"] = ""
    results["page_elements"] = {}
    
    
    results
  end
  
  def self.make_metric_array(val, label)
    if val.nil? || val.blank?
      return [0, label]
    else
      if val.is_a?(String)
        #if val =~ /k/
        val = val.gsub(/,/,'')
        val = val.sub(/\$/,'')
        val = val.gsub(/\n/,'')
        val = val.squish
        val = TextCommon.convert_k_to_number(val)
      end
      
      [val, label]
    end
  end
end
