class House
  include ActiveModel::Model
  attr_accessor :permalink,
    :description, :title, :payload

  def self.from_se_loger(h)
    new(permalink: h["permaLien"],
        title: h["titre"],
        description: h["descriptif"],
        payload: h)
  end

  def thumb
    return "" unless payload
    return payload["firstThumb"] unless payload["photos"]
    if payload["nbPhotos"].to_i > 0
      p = payload["photos"]
      s = p["photo"]
      first = s[0]
      if first
        first["stdUrl"]
      else
        payload["firstThumb"]
      end
    else
      payload["firstThumb"]
    end
  end

  def place
    payload["ville"]
  end

  def price
    payload["prix"]
  end

  def inspect
    super.gsub(/, @payload=\{.*\}/, "")
  end

  def price_unit
    payload["prixUnite"]
  end

  def postal_code
    payload["cp"]
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
