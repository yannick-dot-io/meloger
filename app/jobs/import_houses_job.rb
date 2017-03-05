# Replace records with new ones for houses
class ImportHousesJob < ApplicationJob
  def perform(_args = {})
    House.delete_all
    houses.map(&:save)
  end

  def houses
    SeLogerApi.search(postal_code: ::Configuration.default_regions,
                      max_price: ::Configuration.max_price,
                      min_price: ::Configuration.min_price,
                      terms: ::Configuration.search_terms)
  end
end
