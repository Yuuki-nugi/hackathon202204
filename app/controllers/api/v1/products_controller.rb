module Api
  module V1
    class ProductsController < ApplicationController
      def callback
        events = client.parse_events_from(@body)
        events.each do |event|
          case event
          when Line::Bot::Event::Message
            case event.type
            when Line::Bot::Event::MessageType::Text
              received_text = event.message['text']
              items = get_products_from_yahoo(received_text)
              
              item = items[rand(100)]
              product = Product.new(line_id: event["source"]["userId"], yahoo_product_id: item["code"], is_liked: false)

              while product.duplicate? do
                item = items[rand(100)]
                product.yahoo_product_id = item["code"]
              end

              product.save!
                
              message = {
                type: 'text',
                text: "商品名：#{item["name"]}\n値段：#{item["price"]}円\nURL：#{item["url"]}"
              }
              client.reply_message(event['replyToken'], message)
            end
          end
        end
        head :ok
      end
    end
  end
end
