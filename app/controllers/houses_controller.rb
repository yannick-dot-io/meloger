# Houses
class HousesController < ApplicationController
  def index
    @houses = House.all.order(created_at: :desc)
  end

  def show
    id = params[:id]
    @house = House.find_by(external_id: id)
    raise ActiveRecord::NotFound unless @house
  end
end
