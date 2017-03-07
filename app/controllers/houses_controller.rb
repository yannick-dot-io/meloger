# Houses
class HousesController < ApplicationController
  def index
    @houses = House.all.order(updated_at: :desc)
  end

  def show
    id = params[:id]
    @house = House.find_by(external_id: id)
  end
end
