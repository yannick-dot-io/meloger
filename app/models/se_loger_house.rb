# SeLoger House
class SeLogerHouse < House
  def self.find_or_update(h)
    house = find_or_initialize_by(external_id: h["idAnnonce"].to_s)
    house.attributes_from_se_loger(h)
    house.save!
    house
  end

  def attributes_from_se_loger(h)
    self.postal_code = h["cp"]
    self.price       = h["prix"] || 0
    self.permalink   = h["permaLien"]
    self.title       = h["titre"]
    self.description = h["descriptif"]
    self.payload     = h
  end

  def thumb
    return "" unless payload
    return no_protocol(payload["firstThumb"]) unless payload["photos"]
    if payload["nbPhotos"].to_i.positive?
      first_picture_as_thumb
    else
      no_protocol(payload["firstThumb"])
    end
  end

  def first_picture_as_thumb
    p = payload["photos"]
    s = p["photo"]
    first = s[0]
    if first
      no_protocol(first["stdUrl"])
    else
      no_protocol(payload["firstThumb"])
    end
  end

  def pictures
    if payload["nbPhotos"].to_i == 1
      [payload["photos"]["photo"]].map { |p| Picture.new(p) }
    else
      payload["photos"]["photo"].map { |p| Picture.new(p) }
    end
  end

  def place
    payload["ville"]
  end

  def price_unit
    payload["prixUnite"]
  end

  def number_of_bedrooms
    payload.fetch("nbChambre", "Unknown")
  end

  def number_of_rooms
    payload.fetch("nbPiece", "Unknown")
  end
end
