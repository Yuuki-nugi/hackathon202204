require 'line/bot'
require 'net/http'

class ApplicationController < ActionController::API

    before_action :validate_singnature
    def validate_singnature
        @body = request.body.read
        signature = request.env['HTTP_X_LINE_SIGNATURE']
        unless client.validate_signature(@body, signature)
            render json: { status: 400, message: 'Bad Request'}
        end
    end

    def client
        @client ||= Line::Bot::Client.new { |config|
          config.channel_secret = ENV['LINE_API_CHANNEL_SECRET']
          config.channel_token = ENV['LINE_API_CHANNEL_TOKEN']
        }
    end

    def get_products_from_yahoo()
      yahoo_shopping_uri = "https://shopping.yahooapis.jp/ShoppingWebService/V3/itemSearch"
      params = { appid: ENV['YAHOO_APPLICATION_ID'], query: "母の日" }

      # uriの作成
      uri = URI.parse(yahoo_shopping_uri)
      uri.query = URI.encode_www_form(params)
      
      # httpオブジェクトの作成
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      http.use_ssl = true
      
      # リクエストの送信
      response = http.request(request)
      items = JSON.parse(response.body)
      items["hits"]
    end
end
