class Invoice < ApplicationRecord
    enum status: [:completed, "in progress", :cancelled]

    validates_presence_of :status
    validates_presence_of :created_at
    validates_presence_of :updated_at
    has_many :invoice_items, dependent: :destroy
    has_many :transactions, dependent: :destroy
    has_many :items, through: :invoice_items

    has_many :merchants, through: :items

    belongs_to :customer
    has_many :invoice_items
    has_many :transactions

    has_many :items, through: :invoice_items 


    def self.incomplete_invoices_not_shipped
        select('invoices.*').distinct.joins(:invoice_items).where.not(invoice_items: {status: 2}).order('created_at ASC')
    end


    def total_revenue
        invoice_items
        .select('sum(invoice_items.unit_price * invoice_items.quantity)as total')
        .where(invoice_items:{invoice_id: id})
    end

    def full_name
      customer.first_name + " " + customer.last_name
    end

    def total_price
      invoice_items.sum('unit_price * quantity')
    end


    def discounted_item_revenue(item_id)
      items.joins(merchant: :discounts)
      .where(items: {id: item_id})
      .where('discounts.quantity_threshold <= invoice_items.quantity')
      .select('discounts.id as discount_id, (invoice_items.unit_price * invoice_items.quantity * (1 - discounts.percent / 100.0 ) ) as total')
      .group('total, discount_id')
      .order('total')
      .limit(1)
    end 

    def total_invoice_revenue(merchant_id)
        items
        .where(items: {merchant_id: merchant_id})
        .sum('invoice_items.unit_price * invoice_items.quantity')
    end

    def invoice_items_from_merchant(merchant_id)
      invoice_items.joins(:item)
      .where(items: {merchant_id: merchant_id})
    end

    def discount_total_for_merchant(merchant_id)
      items.joins(merchant: :discounts)
      .where(items: {merchant_id: merchant_id})
      .where('discounts.quantity_threshold <= invoice_items.quantity') 
      .select('items.*, max(invoice_items.unit_price * invoice_items.quantity * (discounts.percent / 100.0 )) as discounted')
      .group('items.id')
      .sum(&:discounted)
    end  

    def discount_total
      items.joins(merchant: :discounts)
      .where('discounts.quantity_threshold <= invoice_items.quantity') 
      .select('items.*, max(invoice_items.unit_price * invoice_items.quantity * (discounts.percent / 100.0 )) as discounted')
      .group('items.id')
      .sum(&:discounted)
    end  

  #   def amount_off
  #   self.invoice_items.joins(:bulk_discounts)
  #                     .where('invoice_items.quantity >= threshold')
  #                     .select('invoice_items.*, percent_off')
  #                     .sum('((invoice_items.unit_price * quantity) * percent_off)')
  # end

    # def discounted
    #   invoice_items.joins(merchants: :discounts)
    #   .where('invoice_items.quantity >= discounts.threshold')
    #   .select('invoice_items.id, max(invoice_items.quantity * invoice_items.unit_price * (discounts.discount * 100.0)) as total_discount')
    #   .group('invoice_items.id')
    #   .sum(&:total_discount)
    # end

end
