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
              product = Product.new(
                line_id: event["source"]["userId"],
                yahoo_product_id: item["code"],
                is_liked: false,
                price: item["price"].to_i,
                name: item["name"],
                url: item["url"]
              )

              while product.duplicate? do
                item = items[rand(100)]

                product = Product.new(
                  line_id: event["source"]["userId"],
                  yahoo_product_id: item["code"],
                  is_liked: false,
                  price: item["price"].to_i,
                  name: item["name"],
                  url: item["url"]
                )
              end

              product.save!
                
              message = [
                {
                  type: 'text',
                  text: "商品名：#{product.name}\n値段：#{product.price}円\nURL：#{product.url}"
                },
                {
                  "type": "template",
                  "altText": "this is a confirm template",
                  "template": 
                {
                  "type": "confirm",
                  "text": "気に入りましたか?",
                  "actions": 
                    [
                      {
                        "type": "postback",
                        "label": "Yes",
                        "data": product.yahoo_product_id
                      },
                      {
                        "type": "postback",
                        "label": "No",
                        "data": "none"
                      }
                    ]
                  }
                }
              ]

              client.reply_message(event['replyToken'], message)
            end
          when Line::Bot::Event::Postback
            data = event['postback']['data']

            if data == "ranking"
              liked_products = Product.get_liked_products
              text = "ランキング！\n"
              liked_products.each_with_index do |product, index|
                text << "\nNo.#{index+1}\n商品名：#{product.name}\n値段：#{product.price}円\nURL：#{product.url}\n"
              end
              message = {
                type: 'text',
                text: text.chomp
              }
            elsif data == "none"
              message = {
                type: 'text',
                text: "もう一度ガチャを回してみてね！"
              }
            else
              line_id = event['source']['userId']
              product = Product.find_by(line_id: line_id, yahoo_product_id: data)
              if !product.is_liked
                product.is_liked = true
                product.save!
              end
              message = {
                type: 'text',
                text: "良い母の日を！"
              }
            end

            client.reply_message(event['replyToken'], message)
          end
        end
        head :ok
      end
    end
  end
end
