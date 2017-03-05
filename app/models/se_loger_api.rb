# API client for se loger
class SeLogerApi
  def self.search(opts = {})
    new.search(opts)
  end

  def search(opts = {})
    qs = setup_options(opts)

    houses = _search(qs)
    return houses unless opts[:terms].any?
    houses.select do |h|
      opts[:terms].any? { |term| h["descriptif"].include?(term) }
    end
  end

  private

  def _search(qs = {})
    resp = client.get("search.xml", qs)
    houses = resp.body["recherche"]["annonces"]["annonce"]
    max_pages = resp.body["recherche"]["pageMax"]
    return houses unless max_pages
    houses + next_pages_search(qs, max_pages)
  end

  def next_pages_search(qs, max_pages)
    current_page = 1
    houses = []
    while current_page < max_pages.to_i
      current_page += 1
      resp = client.get("search.xml", qs.merge(SEARCHpg: current_page))
      houses += resp.body["recherche"]["annonces"]["annonce"]
    end
    houses
  end

  def setup_options(opts = {})
    qs = { naturebien: 1 }
    qs[:cp] = opts.fetch(:postal_code)
    qs[:idtypebien] = opts[:appartment] ? 1 : 2
    qs[:idtt] = opts[:rent] ? 1 : 2
    if opts[:max_price]
      qs[:pxmax] = opts[:max_price]
    end
    if opts[:min_price]
      qs[:pxmin] = opts[:min_price]
    end

    qs[:tri] = case opts[:order]
               when :asc then :a_dt_crea
               else :d_dt_crea
               end
    qs
  end

  def client
    @client ||= Faraday.new("http://ws.seloger.com") do |connection|
      connection.headers["Content-Type"] = "application/xml"
      connection.adapter Faraday.default_adapter
      connection.response :xml, content_type: "text/xml"
    end
  end
end
