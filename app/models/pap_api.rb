# Pap API client
class PapApi
  def self.default_search
    new.search(postal_code: ::Configuration.pap_regions,
               max_price:   ::Configuration.max_price,
               min_price:   ::Configuration.min_price,
               terms:       ::Configuration.search_terms)
  end

  def self.search(opts = {})
    new.search(opts)
  end

  def search(opts = {})
    qs = setup_options(opts)
    houses = _search(qs)
    return houses if opts[:terms].blank?
    houses.select do |h|
      opts[:terms].any? { |term| h["texte"].include?(term) }
    end
  end

  def _search(qs)
    resp = client.get("/immobilier/annonces", qs)
    houses = resp.body["_embedded"]["annonce"]
    houses.map { |h| get(h["_links"]["self"]["href"]) }
  end

  def get(url)
    client.get(URI(url).path).body
  end

  def setup_options(opts = {})
    recherche = { geo: {}, prix: {}, produit: "vente" }
    recherche[:geo][:ids] = opts.fetch(:postal_code)
    recherche[:typesbien] = opts[:appartment] ? %w{appartment} : %w{maison}
    if opts[:max_price]
      recherche[:prix][:max] = opts[:max_price]
    end
    if opts[:min_price]
      recherche[:prix][:min] = opts[:min_price]
    end
    qs = { recherche: recherche }

    qs[:order] = case opts[:order]
                 when :asc then "date-asc"
                 else "date-desc"
                 end
    qs
  end

  def client
    @client ||= Faraday.new("http://ws.pap.fr") do |connection|
      connection.response :logger, ::Logger.new(STDOUT), bodies: true
      connection.adapter Faraday.default_adapter
      connection.response :json, content_type: "application/json"
    end
  end
end
