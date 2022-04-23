class Product < ApplicationRecord
    def duplicate?
        Product.where(line_id: line_id).exists?(yahoo_product_id: yahoo_product_id)
    end
end
