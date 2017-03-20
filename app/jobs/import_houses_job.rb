# Replace records with new ones for houses
class ImportHousesJob < ApplicationJob
  def perform(_args = {})
    se_loger_import
    pap_import
  end

  def pap_import
    houses = PapApi.default_search.map do |h|
      PapHouse.find_or_update(h)
    end
    House.where(source: "pap").where.not(external_id: houses.map(&:external_id)).delete_all
  end

  def se_loger_import
    houses = se_loger_houses_hash.map do |h|
      SeLogerHouse.find_or_update(h)
    end
    House.where(source: "se_loger").where.not(external_id: houses.map(&:external_id)).delete_all
  end

  def se_loger_houses_hash
    SeLogerApi.search(postal_code: ::Configuration.default_regions,
                      max_price: ::Configuration.max_price,
                      min_price: ::Configuration.min_price,
                      terms: ::Configuration.search_terms)
  end
end
