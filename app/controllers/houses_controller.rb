# Houses
class HousesController < ApplicationController
  def show
    id = params[:id]
    @house = SeLogerApi.get(id)
    # @house = Rails.cache.fetch("house-#{id}", expires_in: 10.minutes) do
    #   SeLogerApi.get(id)
    # end
  end
end
