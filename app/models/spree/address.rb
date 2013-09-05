#encoding: utf-8
module Spree
  class Address < ActiveRecord::Base
    belongs_to :country, class_name: "Spree::Country"
    belongs_to :state, class_name: "Spree::State"

    belongs_to :user, class_name: 'Spree::User'

    has_many :shipments

    has_one :user_address, class_name: ::UserAddress

    validates :firstname, :lastname, :address1, :city, :zipcode,  presence: true
    validates :phone, presence: true, if: :require_phone?

    #validate :state_validate

    attr_accessible :firstname, :lastname, :address1, :address2,
                    :city, :zipcode, :country_id, :state_id,
                    :country, :state, :phone, :state_name,
                    :company, :alternative_phone, :is_current, :user_id, :is_ship_address

    alias_attribute :first_name, :firstname
    alias_attribute :last_name, :lastname

    scope :current, where(is_current: true)

    # after_create :set_default
    # after_update :set_default
    # after_destroy :set_default_2
   
    # Disconnected since there's no code to display error messages yet OR matching client-side validation
    def phone_validate
      return if phone.blank?
      n_digits = phone.scan(/[0-9]/).size
      valid_chars = (phone =~ /^[-+()\/\s\d]+$/)
      errors.add :phone, :invalid unless (n_digits > 5 && valid_chars)
    end

    def self.default
      country = Spree::Country.find_by_ios('CN') rescue Spree::Country.first
      new({ country: country }, without_protection: true)
    end

    # Can modify an address if it's not been used in an order (but checkouts controller has finer control)
    # def editable?
    #   new_record? || (shipments.empty? && checkouts.empty?)
    # end

    def full_name
      "#{firstname} #{lastname}".strip
    end

    def state_text
      state.try(:abbr) || state.try(:name) || state_name
    end

    def same_as?(other)
      return false if other.nil?
      attributes.except('id', 'updated_at', 'created_at') == other.attributes.except('id', 'updated_at', 'created_at')
    end

    alias same_as same_as?

    def to_s
      "#{full_name}: #{address1}"
    end

    def clone
      self.class.new(self.attributes.except('id', 'updated_at', 'created_at', 'is_ship_address'))
    end

    def ==(other_address)
      self_attrs = self.attributes
      other_attrs = other_address.respond_to?(:attributes) ? other_address.attributes : {}

      [self_attrs, other_attrs].each { |attrs| attrs.except!('id', 'created_at', 'updated_at', 'order_id') }

      self_attrs == other_attrs
    end

    def empty?
      attributes.except('id', 'created_at', 'updated_at', 'order_id', 'country_id').all? { |_, v| v.nil? }
    end

    # Generates an ActiveMerchant compatible address hash
    def active_merchant_hash
      {
        name: full_name,
        address1: address1,
        address2: address2,
        city: city,
        state: state_text,
        zip: zipcode,
        country: country.try(:iso),
        phone: phone
      }
    end

    def state_name
      state.name
    end

    def country_name
      country.name
    end

    def full_address
      "#{address1}, #{city} #{state_name} #{country_name}, #{zipcode}"
    end

    private

      def user_ship_address
         user.ship_address.order("created_at DESC") 
      end

      def update_to_default
        newest_address = user_ship_address.try(:first)
        newest_address.update_column(:is_current, true) if newest_address
      end

      def set_default
        # 如过没有默认地址，设置最新的地址为默认
        if user_ship_address.current.blank?
          update_to_default
          return true
        end

        if self.is_current == '1'
          user_ship_address.update_all(:is_current => false)
          update_to_default
          return true
        end
      end

      def set_default_2
        if !user_ship_address.blank? && user_ship_address.current.blank?
          update_to_default
        end
      end

      def require_phone?
        true
      end

      def state_validate
        # Skip state validation without country (also required)
        # or when disabled by preference
        return if country.blank? || !Spree::Config[:address_requires_state]
        return unless country.states_required

        # ensure associated state belongs to country
        if state.present?
          if state.country == country
            self.state_name = nil #not required as we have a valid state and country combo
          else
            if state_name.present?
              self.state = nil
            else
              errors.add(:state, :invalid)
            end
          end
        end

        # ensure state_name belongs to country without states, or that it matches a predefined state name/abbr
        if state_name.present?
          if country.states.present?
            states = country.states.find_all_by_name_or_abbr(state_name)

            if states.size == 1
              self.state = states.first
              self.state_name = nil
            else
              errors.add(:state, :invalid)
            end
          end
        end

        # ensure at least one state field is populated
        errors.add :state, :blank if state.blank? && state_name.blank?
      end

  end
end
