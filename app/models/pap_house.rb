# PAP house
class PapHouse < House
  def self.find_or_update(h)
    house = find_or_initialize_by(external_id: h["id"].to_s)
    house.attributes_from_pap(h)
    house.save!
    house
  end

  def attributes_from_pap(h)
    place            = h["_embedded"]["place"][0]
    self.postal_code = place["slug"].split("-").last
    self.price       = h.fetch("prix", 0)
    self.permalink   = h["_links"]["desktop"]["href"]
    self.title       = place["title"]
    self.description = h["texte"]
    self.payload     = h
  end

  def reference
    "pap"
  end

  def thumb
    return "" unless payload
    pics = payload.fetch("_embedded", {})["photo"]
    return "" unless pics && pics.any?
    no_protocol(pics[0]["_links"]["self"]["href"])
  end

  def pictures
    payload["_embedded"]["photo"].map { |p| Picture.new(p) }
  end

  def place
    payload["_embedded"]["place"][0]["title"]
  end

  def price_unit
    "€"
  end

  def number_of_bedrooms
    payload.fetch("nb_chambres_max", "Unknown")
  end

  def number_of_rooms
    payload.fetch("nb_pieces", "Unknown")
  end
end
