# Configuration for defaults in the app
module Configuration
  def self.max_price
    300_000
  end

  def self.min_price
    150_000
  end

  def self.search_terms
    ENV.fetch("SEARCH_TERMS") do
      "dépendance,longère"
    end.split(",").map(&:strip)
  end

  def self.default_regions
    ENV.fetch("REGIONS", "10,21,51,58,71,89")
  end

  def self.pap_regions
    [373, 385, 415, 422, 435, 453, 465]
  end
end
