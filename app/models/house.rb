# House model
class House < ApplicationRecord
  validates :external_id, uniqueness: { scope: :source }
  self.inheritance_column = :source

  def inspect
    super.gsub(/, @payload=\{.*\}/, "")
  end

  def surface
    payload.fetch("surface", "0").to_s
  end

  def surface_unit
    payload.fetch("surfaceUnite", "m2")
  end

  private

  def no_protocol(url)
    return unless url
    url.sub(/http(s)?:/, "")
  end
end
