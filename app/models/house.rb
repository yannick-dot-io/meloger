# House model
class House < ApplicationRecord
  def self.find_or_update_from_se_loger(h)
    house = find_or_initialize_by(external_id: h["idAnnonce"].to_s)
    house.postal_code = h["cp"]
    house.price       = h["prix"]
    house.permalink   = h["permaLien"]
    house.title       = h["titre"]
    house.description = h["descriptif"]
    house.created_at  = h["dtCreation"]
    house.updated_at  = h["dtFraicheur"]
    house.payload     = h
    house.save
  end

  def thumb
    return "" unless payload
    return payload["firstThumb"] unless payload["photos"]
    if payload["nbPhotos"].to_i.positive?
      first_picture_as_thumb
    else
      payload["firstThumb"]
    end
  end

  def first_picture_as_thumb
    p = payload["photos"]
    s = p["photo"]
    first = s[0]
    if first
      first["stdUrl"]
    else
      payload["firstThumb"]
    end
  end

  def pictures
    payload["photos"]["photo"].map { |p| Picture.new(p) }
  end

  def place
    payload["ville"]
  end

  def inspect
    super.gsub(/, @payload=\{.*\}/, "")
  end

  def price_unit
    payload["prixUnite"]
  end

  def surface
    payload.fetch("surface", "0")
  end

  def surface_unit
    payload.fetch("surfaceUnite", "m2")
  end

  def number_of_bedrooms
    payload.fetch("nbChambre", "Unknown")
  end

  def number_of_rooms
    payload.fetch("nbPiece", "Unknown")
  end
end
