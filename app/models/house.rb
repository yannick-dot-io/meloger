# House model
class House < ApplicationRecord
  validates :external_id, uniqueness: true

  def self.find_or_update_from_se_loger(h)
    house = find_or_initialize_by(external_id: h["idAnnonce"].to_s)
    house.source      = "se_loger"
    house.postal_code = h["cp"]
    house.price       = h["prix"] || 0
    house.permalink   = h["permaLien"]
    house.title       = h["titre"]
    house.description = h["descriptif"]
    house.payload     = h
    house.save!
    house
  end

  def self.find_or_update_from_pap(h)
    house = find_or_initialize_by(external_id: h["id"].to_s)
    house.source      = "pap"
    house.postal_code = h["_embedded"]["place"][0]["slug"].split("-").last
    house.price       = h["prix"] || 0
    house.permalink   = h["_links"]["desktop"]["href"]
    house.title       = h["_embedded"]["place"][0]["title"]
    house.description = h["texte"]
    house.payload     = h
    house.save!
    house
  end

  def thumb
    return "" unless payload
    case source
    when "se_loger" then se_loger_thumb
    when "pap" then pap_thumb
    end
  end

  def pap_thumb
    return "" unless payload["_embedded"]["photo"] && payload["_embedded"]["photo"].any?
    no_protocol(payload["_embedded"]["photo"][0]["_links"]["self"]["href"])
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
    when "se_loger" then payload["photos"]["photo"].map { |p| Picture.new(p) }
    when "pap" then payload["_embedded"]["photo"].map { |p| Picture.new(p) }
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
