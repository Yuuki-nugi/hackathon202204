module Api
  module V1
    class ProductsController < ApplicationController
      def callback
        body = request.body.read
        raise "bodyがnullだよ" if body.nil?
        events = client.parse_events_from(body)
        raise "eventsがnullだよ" if events.length == 0
        events.each do |event|
          case event
          when Line::Bot::Event::Message
            case event.type
            when Line::Bot::Event::MessageType::Text
              message = {
                type: 'text',
                text: event.message['text']
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
