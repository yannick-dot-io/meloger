class Picture
  attr_accessor :payload

  def initialize(payload)
    @payload = payload
  end

  def url
    payload["bigUrl"] || payload["stdUrl"] || payload["thbUrl"]
  end
end
