class RegionsController < ApplicationController
  def show
    region = params[:id]
    @houses = Rails.cache.fetch("regions-#{region}-houses", expires_in: 10.minutes) do
      SeLogerApi.search(postal_code: region,
                        max_price: ::Configuration.max_price,
                        min_price: ::Configuration.min_price,
                        terms: ::Configuration.search_terms)
    end
  end

  def index
    @houses = Rails.cache.fetch("regions-#{default_regions}-houses", expires_in: 10.minutes) do
      SeLogerApi.search(postal_code: default_regions,
                        max_price: ::Configuration.max_price,
                        min_price: ::Configuration.min_price,
                        terms: ::Configuration.search_terms)
    end
    render :show
  end

  def default_regions
    ENV.fetch("REGIONS", "51,21,58,71,89")
  end
end
