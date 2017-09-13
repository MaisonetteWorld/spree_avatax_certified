require 'json'
require 'net/http'
require 'base64'
require 'logger'

module SpreeAvataxCertified
  class Address
    attr_reader :order, :addresses

    def initialize(order, stock_location)
      @order = order
      @ship_address = order.ship_address
      @stock_location = stock_location
      @addresses = []
      @logger ||= AvataxHelper::AvataxLog.new('avalara_order_addresses', 'SpreeAvataxCertified::Address', "Building Addresses for Order#: #{order.number}")
      build_addresses
      @logger.debug @addresses
    end

    def build_addresses
      origin_address
      order_ship_address unless @ship_address.nil?
      origin_ship_addresses
    end

    def origin_address
      get_nexus
      addresses << {
        AddressCode: "Orig",
        Line1: @stock_location.address1,
        Line2: @stock_location.address2,
        City: @stock_location.city,
        PostalCode: @stock_location.zipcode,
        Country: @stock_location.country.try(:iso),
        Region: @stock_location.state_text
      }
    end

    def order_ship_address
      addresses << {
        AddressCode: 'Dest',
        Line1: @ship_address.address1,
        Line2: @ship_address.address2,
        City: @ship_address.city,
        Region: @ship_address.state_text,
        Country: @ship_address.country.try(:iso),
        PostalCode: @ship_address.zipcode
      }
    end

    def origin_ship_addresses
      if order.shipments.any?
        # stock_loc_ids = order.shipments.pluck(:stock_location_id).uniq
        # Spree::StockLocation.where(id: stock_loc_ids).each do |stock_location|
        #   stock_location = get_nexus(stock_location)
          addresses << {
            AddressCode: "#{@stock_location.id}",
            Line1: @stock_location.address1,
            Line2: @stock_location.address2,
            City: @stock_location.city,
            PostalCode: @stock_location.zipcode,
            Country: @stock_location.country.try(:iso)
          }
        # end
      end
    end

    def get_nexus
      nexus = @stock_location.taxon.stock_locations.detect { |stock_loc| stock_loc.state_id == @ship_address.state_id }
      @stock_location = nexus ? nexus : @stock_location.taxon.stock_locations[0]
    end

    def validate
      return 'Address validation disabled' unless address_validation_enabled?
      return @ship_address if @ship_address.nil?

      address_hash = {
        Line1: @ship_address.address1,
        Line2: @ship_address.address2,
        City: @ship_address.city,
        Region: @ship_address.state.try(:abbr),
        Country: @ship_address.country.try(:iso),
        PostalCode: @ship_address.zipcode
      }

      validation_response(address_hash)
    end

    def country_enabled?
      enabled_countries.include?(@ship_address.try(:country).try(:name))
    end

    private

    def validation_response(address)
      uri = URI(service_url + address.to_query)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      res = http.get(uri.request_uri, 'Authorization' => credential)

      response = JSON.parse(res.body)
      address = response['Address']

      if address['City'] != @ship_address.city || address['Region'] != @ship_address.state.abbr
        response['ResultCode'] = 'Error'
        response['Messages'] = [
          {
            'Summary' => "Did you mean #{address['Line1']}, #{address['City']}, #{address['Region']}, #{address['PostalCode']}?"
          }
        ]
      end

      return response
    rescue => e
      "error in address validation: #{e}"
    end

    def address_validation_enabled?
      Spree::Config.avatax_address_validation && country_enabled?
    end

    def credential
      'Basic ' + Base64.encode64(account_number + ':' + license_key)
    end

    def service_url
      Spree::Config.avatax_endpoint + AVATAX_SERVICEPATH_ADDRESS + 'validate?'
    end

    def license_key
      Spree::Config.avatax_license_key
    end

    def account_number
      Spree::Config.avatax_account
    end

    def enabled_countries
      Spree::Config.avatax_address_validation_enabled_countries
    end
  end
end
