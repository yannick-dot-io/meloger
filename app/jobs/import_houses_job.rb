# Replace records with new ones for houses
class ImportHousesJob < ApplicationJob
  def perform(_args = {})
    houses = houses_hash.map do |h|
      House.find_or_update_from_se_loger(h)
    end
    House.where.not(external_id: houses.map(&:external_id)).delete_all
  end

  def houses_hash
    SeLogerApi.search(postal_code: ::Configuration.default_regions,
                      max_price: ::Configuration.max_price,
                      min_price: ::Configuration.min_price,
                      terms: ::Configuration.search_terms)
  end
end
