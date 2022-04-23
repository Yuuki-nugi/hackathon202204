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
                
              message = [
                {
                  type: 'text',
                  text: "商品名：#{item["name"]}\n値段：#{item["price"]}円\nURL：#{item["url"]}"
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
                        "data": item["code"]
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
            product_id = event['postback']['data']
            if product_id == "none"
              message = {
                type: 'text',
                text: "もう一度ガチャを回してみてね！"
              }
            else
              line_id = event['source']['userId']
              product = Product.find_by(line_id: line_id, yahoo_product_id: product_id)
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
