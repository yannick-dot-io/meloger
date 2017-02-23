class SeLogerApi
  def self.search(opts = {})
    new.search(opts)
  end

  def self.get(id)
    new.get(id)
  end

  def search(opts = {})
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
    when :asc; :a_dt_crea
    else :d_dt_crea
    end

    resp = client.get("search.xml", qs)
    houses = resp.body["recherche"]["annonces"]["annonce"]
    if resp.body["recherche"]["pageMax"]
      current_page = resp.body["recherche"]["pageCourante"].to_i
      while current_page < resp.body["recherche"]["pageMax"].to_i
        current_page += 1
        resp = client.get("search.xml", qs.merge(SEARCHpg: current_page))
        houses += resp.body["recherche"]["annonces"]["annonce"]
      end
    end
    houses = houses.map { |h| House.from_se_loger(h) }
    return houses unless opts[:terms].any?
    houses.select do |h|
      opts[:terms].any? { |term| h.description.include?(term) }
    end
  end

  def get(id)
    resp = client.get("annonceDetail.xml", idAnnonce: id)
    House.from_se_loger(resp.body["detailAnnonce"])
  end

  def client
    @client ||= Faraday.new("http://ws.seloger.com") do |connection|
      connection.headers["Content-Type"] = "application/xml"
      connection.adapter Faraday.default_adapter
      connection.response :xml, content_type: "text/xml"
    end
  end
end
