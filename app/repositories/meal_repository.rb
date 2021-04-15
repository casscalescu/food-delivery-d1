require 'csv'
require_relative '../models/meal'
require_relative 'base_repository'

class MealRepository < BaseRepository
  def edit_meal(meal_id, meal_name, meal_price)
    meal = @elements[meal_id]
    meal.name = meal_name
    meal.price = meal_price
    save_csv
  end

  private

  # This private method is REFERENCED/CALLED in
  # BaseRepository.
  #
  # It needs to be defined here because MealRepository
  # and CustomerRepository differ in the type of elements
  # they are trying to create (Meal and Customer)
  #
  def build_element(row)
    # Price MUST be an integer
    row[:price] = row[:price].to_i
    Meal.new(row) # returns a Meal instance
  end
end
