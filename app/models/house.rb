# House model
class House < ApplicationRecord
  validates :external_id, uniqueness: true

  def self.find_or_update_from_se_loger(h)
    house = find_or_initialize_by(external_id: h["idAnnonce"].to_s)
    house.attributes_from_se_loger(h)
    house.save!
    house
  end

  def self.find_or_update_from_pap(h)
    house = find_or_initialize_by(external_id: h["id"].to_s)
    house.attributes_from_pap(h)
    house.save!
    house
  end

  def attributes_from_se_loger(h)
    self.source      = "se_loger"
    self.postal_code = h["cp"]
    self.price       = h["prix"] || 0
    self.permalink   = h["permaLien"]
    self.title       = h["titre"]
    self.description = h["descriptif"]
    self.payload     = h
  end

  def attributes_from_pap(h)
    self.source      = "pap"
    place            = h["_embedded"]["place"][0]
    self.postal_code = place["slug"].split("-").last
    self.price       = h.fetch("prix", 0)
    self.permalink   = h["_links"]["desktop"]["href"]
    self.title       = place["title"]
    self.description = h["texte"]
    self.payload     = h
  end

  def thumb
    return "" unless payload
    case source
    when "se_loger" then se_loger_thumb
    when "pap" then pap_thumb
    end
  end

  def pap_thumb
    pics = payload.fetch("_embedded", {})["photo"]
    return "" unless pics && pics.any?
    no_protocol(pics[0]["_links"]["self"]["href"])
  end

  def se_loger_thumb
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
    case source
    when "se_loger" then se_loger_pictures
    when "pap" then payload["_embedded"]["photo"].map { |p| Picture.new(p) }
    end
  end

  def se_loger_pictures
    if payload["nbPhotos"].to_i == 1
      [payload["photos"]["photo"]].map { |p| Picture.new(p) }
    else
      payload["photos"]["photo"].map { |p| Picture.new(p) }
    end
  end

  def place
    case source
    when "se_loger" then payload["ville"]
    when "pap" then payload["_embedded"]["place"][0]["title"]
    end
  end

  def inspect
    super.gsub(/, @payload=\{.*\}/, "")
  end

  def price_unit
    case source
    when "se_loger" then payload["prixUnite"]
    when "pap" then "eur"
    end
  end

  def surface
    payload.fetch("surface", "0").to_s
  end

  def surface_unit
    payload.fetch("surfaceUnite", "m2")
  end

  def number_of_bedrooms
    case source
    when "se_loger" then payload.fetch("nbChambre", "Unknown")
    when "pap" then payload.fetch("nb_chambres_max", "Unknown")
    end
  end

  def number_of_rooms
    case source
    when "se_loger" then payload.fetch("nbPiece", "Unknown")
    when "pap" then payload.fetch("nb_pieces", "Unknown")
    end
  end

  private

  def no_protocol(url)
    return unless url
    url.sub(/http(s)?:/, "")
  end
end
