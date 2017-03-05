# Replace records with new ones for houses
class ImportHousesJob < ApplicationJob
  def perform(_args = {})
    House.where.not(external_id: houses.map(&:external_id)).delete_all
    houses.each do |h|
      house = House.find_or_initialize_by(external_id: h.external_id)
      house.postal_code = h.postal_code
      house.price       = h.price
      house.permalink   = h.permalink
      house.title       = h.title
      house.description = h.description
      house.created_at  = h.created_at
      house.updated_at  = h.updated_at
      house.payload     = h.payload
      house.save
    end
  end

  def houses
    SeLogerApi.search(postal_code: ::Configuration.default_regions,
                      max_price: ::Configuration.max_price,
                      min_price: ::Configuration.min_price,
                      terms: ::Configuration.search_terms)
  end
end
