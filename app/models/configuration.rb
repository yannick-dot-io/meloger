module Configuration
  def self.max_price
    300_000
  end

  def self.min_price
    100_000
  end

  def self.search_terms
    ["dépendance",
     "longère"]
  end

  def self.default_regions
    ENV.fetch("REGIONS", "51,21,58,71,89")
  end
end
