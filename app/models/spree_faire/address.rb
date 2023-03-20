module SpreeFaire
  class Address

    attr_accessor :data, :address, :address_data, :user

    def initialize(address_data, user)
      @user = user
      @data = address_data
      @address_data = {}
      @address = nil
    end

    def build_address
      # Added as Faire does not include state for Australian orders
      check_state_for_australian_addresses

      country = get_country_for(@data[:country])
      state = get_state_for(@data[:state], country)
      name_array = @data[:name].split
      firstname = name_array[0]
      lastname = name_array[1]
      # Start with these fields cause they are safe
      @address_data = {
        address1: @data[:address1],
        address2: @data[:address2],
        city: @data[:city],
        zipcode: @data[:postal_code],
        firstname: (firstname || 'Faire'),
        lastname: (lastname || 'Buyer'),
        state_name: state.name,
        state: state,
        company: @data[:company],
        country: country,
        phone: convert_phone(@data[:phone] || @data[:phone_secondary]) || '0000000000'
      }

      # Check if we are using spree address book
      # Commented as no user
      if `gem list`.include? 'spree_address_book'
        @address_data = @address_data.merge(user: @user, default: false)
      end
      
      @address_data
    end

    def get_country_for(name)
      Spree::Country.find_by(name: name)
    end

    def get_state_for(name, country_id)
      Spree::State.find_by(name: name, country: country_id)
    end
    
    def check_state_for_australian_addresses
      if @data[:state].nil? && @data[:country] == "Australia"
        case @data[:postal_code].first
        when "0"
          @data[:state] = "Northern Territory"
        when "2"
          @data[:state] = "New South Wales"
        when "3"
          @data[:state] = "Victoria"
        when "4"
          @data[:state] = "Queensland"
        when "5"
          @data[:state] = "South Australia"
        when "6"
          @data[:state] = "Western Australia"
        when "7"
          @data[:state] = "Tasmania"
        end
      end
    end

    def convert_phone(phone_number)
      return nil if phone_number.blank? ||
                    phone_number.length < 10 ||
                    phone_number.length > 15
      phone_number
    end

  end
end
