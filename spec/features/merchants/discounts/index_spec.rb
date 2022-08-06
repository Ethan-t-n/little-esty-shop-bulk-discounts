require 'rails_helper'

RSpec.describe "merchant discounts index", type: :feature do

    it 'has a discounts for that merchant' do
        merchant_1 = Merchant.create!(name: "Schroeder-Jerde", created_at: Time.now, updated_at: Time.now)
        merchant_2 = Merchant.create!(name: "Klein, Rempel and Jones", created_at: Time.now, updated_at: Time.now)

        discount_1 = Discount.create!(percent: 20, quantity_threshold: 10, merchant_id: merchant_1.id)
        discount_2 = Discount.create!(percent: 10, quantity_threshold: 5, merchant_id: merchant_1.id)
        discount_3 = Discount.create!(percent: 15, quantity_threshold: 8, merchant_id: merchant_2.id)

        visit "/merchants/#{merchant_1.id}/discounts"

        expect(page).to_not have_content("Percent Discount: 15%")
        expect(page).to_not have_content("Quantity Threshold: 10")

         within('#discounts') do
            expect(page).to have_content("Percent Discount: 20%")
            expect(page).to have_content("Quantity Threshold Of: 10")
            expect(page).to have_content("Percent Discount: 10%")
            expect(page).to have_content("Quantity Threshold Of: 5")
        end

        click_on("View Discount #{discount_1.id}")
        expect(current_path).to eq("/merchants/#{merchant_1.id}/discounts/#{discount_1.id}")
    end
end