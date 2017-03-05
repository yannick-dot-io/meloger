# Wrapper for a picture
class Picture
  attr_accessor :payload

  def initialize(payload)
    @payload = payload
  end

  def url
    no_protocol(payload["bigUrl"] || payload["stdUrl"] || payload["thbUrl"])
  end

  private

  def no_protocol(url)
    url.sub(/http(s)?:/, "")
  end
end
