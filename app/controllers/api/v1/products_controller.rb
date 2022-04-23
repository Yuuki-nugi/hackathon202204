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
              items = get_products_from_yahoo()
              message = {
                type: 'text',
                text: items[0]["name"]
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
