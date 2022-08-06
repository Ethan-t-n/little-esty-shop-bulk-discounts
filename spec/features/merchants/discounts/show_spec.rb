require 'rails_helper'

RSpec.describe "merchant discounts show page", type: :feature do

    it 'has a discounts for that merchant' do
        merchant_1 = Merchant.create!(name: "Schroeder-Jerde", created_at: Time.now, updated_at: Time.now)

        discount_1 = Discount.create!(percent: 20, quantity_threshold: 10, merchant_id: merchant_1.id)
       
        visit "/merchants/#{merchant_1.id}/discounts/#{discount_1.id}"

        expect(page).to have_content("Percent Discount: 20%")
        expect(page).to have_content("Quantity Threshold: 10")
    end
end