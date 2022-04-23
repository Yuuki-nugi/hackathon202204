require 'line/bot'

class ApplicationController < ActionController::API

    before_action :validate_singnature
    def validate_singnature
        body = request.body.read
        signature = request.env['HTTP_X_LINE_SIGNATURE']
        unless client.validate_signature(body, signature)
            render json: { status: 400, message: 'Bad Request'}
        end
    end

    def client
        @client ||= Line::Bot::Client.new { |config|
          config.channel_secret = ENV['LINE_API_CHANNEL_SECRET']
          config.channel_token = ENV['LINE_API_CHANNEL_TOKEN']
        }
    end

end
