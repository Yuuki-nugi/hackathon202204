class Product < ApplicationRecord
    def duplicate?
        Product.where(line_id: line_id).exists?(yahoo_product_id: yahoo_product_id)
    end

    class << self
      def get_liked_products
        counts = Product
          .select('yahoo_product_id, count(yahoo_product_id) as liked_count')
          .where(is_liked: true)
          .group(:yahoo_product_id)
          .order('liked_count desc')
          .first(3)
        Product.select('yahoo_product_id, price, name, url').where(yahoo_product_id: counts.map(&:yahoo_product_id)).distinct()
      end
    end
end
