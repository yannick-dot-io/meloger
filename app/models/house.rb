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
      first["stdUrl"]
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
end
