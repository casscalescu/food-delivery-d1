require 'csv'

# This Class is simply a wrapper/container to
# encapsulate SHARED code. It will never be
# initialized in our app: no BaseRepository.new

class BaseRepository
  CSV_DEFAULT_OPTIONS = {
    headers: :first_row,
    header_converters: :symbol
  }

  def initialize(csv_file)
    @csv_file = csv_file
    # @elements: Generic name. This Array will store either
    # Meal or Customer instances.
    @elements = []
    @next_id = 1
    load_csv if File.exist?(@csv_file)
  end

  # receives a Meal/Customer instance
  def create(instance)
    # set element id
    # again, this works because BOTH Meal and Customer
    # have a SETTER for :id
    instance.id = @next_id
    # push element into elements
    @elements << instance
    # increment next_id
    @next_id += 1
    # save changes
    save_csv
  end

  def all
    @elements
  end

  def find(id)
    # select => []
    # This works because BOTH Meal and Customer
    # have a GETTER for :id, i.e.:
    #
    # Meal.new({}).id => 6
    # Customer.new({}).id => 8
    @elements.find { |element| element.id == id }
  end

  def remove_at(index)
    @elements.delete_at(index)
    save_csv
  end

  private

  def load_csv
    CSV.foreach(@csv_file, CSV_DEFAULT_OPTIONS) do |row|
      # Both Meal and Customer have :id and :name
      # so we can deal with them in the BaseRepository
      #
      # :id needs to be converted into integer
      # name doesnt need to be converted
      row[:id] = row[:id].to_i

      # row is a Hash-like object
      # Because we need to do Meal.new or Customer.new
      # depending on whether we are in a MealRepository
      # or a CustomerRepository (which inherit from BaseRepository)
      # the build_element will be implemented in the
      # CHILD repositories (see MealRepository and CustomerRepository)
      @elements << build_element(row)
    end

    @next_id = @elements.empty? ? 1 : @elements.last.id + 1
  end

  def save_csv
    # If we are saving, for sure there must be
    # at least one element (a Meal or a Customer)...
    CSV.open(@csv_file, 'wb') do |csv|
      # Therefore, we grab this first element from the Array
      # and get its class (it will be either Meal or Customer)
      # what are its headers:
      #
      # (see both models for implementation)
      csv << @elements.first.class.csv_headers
      @elements.each do |element|
        # Likewise, because Meal and Customer have different
        # attributes/properties, we ask the instance to
        # convert itself into an Array
        #
        # (see both models for implementation)
        csv << element.to_array
      end
    end
  end
end
