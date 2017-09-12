require 'logging'
require_dependency 'spree/order'

module Spree
  class AvalaraTransaction < ActiveRecord::Base
    AVALARA_TRANSACTION_LOGGER = AvataxHelper::AvataxLog.new('post_order_to_avalara', __FILE__)

    belongs_to :order
    belongs_to :reimbursement
    belongs_to :refund
    validates :order, presence: true
    validates :order_id, uniqueness: true
    has_many :adjustments, as: :source

    def lookup_avatax
      post_order_to_avalara(false, 'SalesOrder')
    end

    def commit_avatax(doc_type = nil, refund = nil)
      if tax_calculation_enabled?
        if %w(ReturnInvoice ReturnOrder).include?(doc_type)
          post_return_to_avalara(false, doc_type, refund)
        else
          post_order_to_avalara(false, doc_type)
        end
      else
        { TotalTax: '0.00' }
      end
    end

    def commit_avatax_final(doc_type = nil, refund = nil)
      if document_committing_enabled?
        if tax_calculation_enabled?
          if %w(ReturnInvoice ReturnOrder).include?(doc_type)
            post_return_to_avalara(true, doc_type, refund)
          else
            post_order_to_avalara(true, doc_type)
          end
        else
          { TotalTax: '0.00' }
        end
      else
        AVALARA_TRANSACTION_LOGGER.debug 'avalara document committing disabled'
        'avalara document committing disabled'
      end
    end

    def cancel_order
      cancel_order_to_avalara('SalesInvoice') if tax_calculation_enabled?
    end

    private

    def cancel_order_to_avalara(doc_type = 'SalesInvoice')
      AVALARA_TRANSACTION_LOGGER.info('cancel order to avalara')
      stock_loc_ids = order.shipments.pluck(:stock_location_id).uniq
      Spree::StockLocation.where(id: stock_loc_ids).each do |stock_location|
        cancel_tax_request = {
          CompanyCode: stock_location.taxon.name,
          DocType: doc_type,
          DocCode: order.number,
          CancelCode: 'DocVoided'
        }

        mytax = TaxSvc.new
        cancel_tax_result = mytax.cancel_tax(cancel_tax_request)
      end
      AVALARA_TRANSACTION_LOGGER.debug cancel_tax_result

      if cancel_tax_result == 'Error in Cancel Tax'
        return 'Error in Cancel Tax'
      else
        return cancel_tax_result
      end
    end

    def post_order_to_avalara(commit = false, doc_type = nil)
      AVALARA_TRANSACTION_LOGGER.info('post order to avalara')
      final_tax = {}
      tax_result = ""
      stock_loc_ids = order.shipments.pluck(:stock_location_id).uniq
      Spree::StockLocation.where(id: stock_loc_ids).each do |stock_location|

        avatax_address = SpreeAvataxCertified::Address.new(order, stock_location)
        avatax_line = SpreeAvataxCertified::Line.new(order, doc_type, stock_location)

        response = avatax_address.validate

        unless response.nil?
          if response['ResultCode'] == 'Success'
            AVALARA_TRANSACTION_LOGGER.info('Address Validation Success')
          else
            AVALARA_TRANSACTION_LOGGER.info('Address Validation Failed')
          end
        end

        doc_date = order.completed? ? order.completed_at.strftime('%F') : Date.today.strftime('%F')

        gettaxes = {
          DocCode: order.number,
          DocDate: doc_date,
          Discount: order.adjustments.eligible.promotion.sum(:amount).abs.to_s,
          Commit: commit,
          DocType: doc_type ? doc_type : 'SalesOrder',
          Addresses: avatax_address.addresses,
          Lines: avatax_line.lines
        }.merge(base_tax_hash)

        if !business_id_no.blank?
          gettaxes[:BusinessIdentificationNo] = business_id_no
        end

        AVALARA_TRANSACTION_LOGGER.debug gettaxes

        mytax = TaxSvc.new
        gettaxes[:CompanyCode] = stock_location.taxon.name
        gettaxes[:ExemptionNo] = stock_location.country.try(:iso) != "US" ? 1 : order.user.try(:exemption_number)
        tax_result = mytax.get_tax(gettaxes)
        unless tax_result == 'error in Tax'
          final_tax == {} ? final_tax = tax_result : merge_taxes(final_tax, tax_result)
        end
      end
      binding.pry
      AVALARA_TRANSACTION_LOGGER.info_and_debug('tax result', tax_result)
      return { TotalTax: '0.00' } if tax_result == 'error in Tax'
      return final_tax if tax_result['ResultCode'] == 'Success'
    end

    def post_return_to_avalara(commit = false, doc_type = nil, refund = nil)
      AVALARA_TRANSACTION_LOGGER.info('starting post return order to avalara')

      avatax_address = SpreeAvataxCertified::Address.new(order)
      avatax_line = SpreeAvataxCertified::Line.new(order, doc_type, refund)

      taxoverride = {
        TaxOverrideType: 'TaxDate',
        Reason: 'Return',
        TaxDate: order.completed_at.strftime('%F')
      }

      gettaxes = {
        DocCode: order.number.to_s + '.' + refund.id.to_s,
        DocDate: Date.today.strftime('%F'),
        Commit: commit,
        DocType: doc_type ? doc_type : 'ReturnOrder',
        Addresses: avatax_address.addresses,
        Lines: avatax_line.lines
      }.merge(base_tax_hash)

      if !business_id_no.blank?
        gettaxes[:BusinessIdentificationNo] = business_id_no
      end

      gettaxes[:TaxOverride] = taxoverride

      AVALARA_TRANSACTION_LOGGER.debug gettaxes

      mytax = TaxSvc.new

      tax_result = mytax.get_tax(gettaxes)

      AVALARA_TRANSACTION_LOGGER.info_and_debug('tax result', tax_result)

      return { TotalTax: '0.00' } if tax_result == 'error in Tax'
      return tax_result if tax_result['ResultCode'] == 'Success'
    end
    def merge_taxes(final_tax, tax_result)
      final_tax["TotalAmount"] = (final_tax["TotalAmount"].to_f.round(2) + tax_result["TotalAmount"].to_f.round(2)).to_s
      final_tax["TotalDiscount"] = (final_tax["TotalDiscount"].to_f.round(2) + tax_result["TotalDiscount"].to_f.round(2)).to_s
      final_tax["TotalExemption"] = (final_tax["TotalExemption"].to_f.round(2) + tax_result["TotalExemption"].to_f.round(2)).to_s
      final_tax["TotalTaxable"] = (final_tax["TotalTaxable"].to_f.round(2) + tax_result["TotalTaxable"].to_f.round(2)).to_s
      final_tax["TotalTax"] = (final_tax["TotalTax"].to_f.round(2) + tax_result["TotalTax"].to_f.round(2)).to_s
      final_tax["TotalTaxCalculated"] = (final_tax["TotalTaxCalculated"].to_f.round(2) + tax_result["TotalTaxCalculated"].to_f.round(2)).to_s
      final_tax["TaxLines"].concat(tax_result["TaxLines"])
      final_tax["TaxAddresses"].concat(tax_result["TaxAddresses"])
    end
    def base_tax_hash
      # CompanyCode: Spree::Config.avatax_company_code,
      # ExemptionNo: order.user.try(:exemption_number),
      {
        CustomerCode: customer_code,
        CustomerUsageType: order.customer_usage_type,
        Client:  avatax_client_version,
        ReferenceCode: order.number,
        DetailLevel: 'Tax',
        CurrencyCode: order.currency
      }
    end

    def customer_code
      order.user ? order.user.id : order.email
    end

    def business_id_no
      order.user.try(:vat_id)
    end

    def avatax_client_version
      AVATAX_CLIENT_VERSION || 'SpreeExtV3.0'
    end

    def document_committing_enabled?
      Spree::Config.avatax_document_commit
    end

    def tax_calculation_enabled?
      Spree::Config.avatax_tax_calculation
    end
  end
end
