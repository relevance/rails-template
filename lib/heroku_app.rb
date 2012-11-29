require 'httparty'

class HerokuApp
  include HTTParty

  headers 'Accept' => 'application/json'
  format :json

  attr_accessor :api_key, :app_name

  def initialize(options = {})
    @api_key = options[:api_key] || ENV['HEROKU_API_KEY']
    @app_name = options[:app_name]
    raise "No API key" unless @api_key
    self.class.basic_auth "", @api_key
  end

  def create(params = {})
    response = self.class.post("https://api.heroku.com/apps/#{params[:app_name]}")
    if ok?(response)
      @app_name = response.parsed_response["name"]
      return response.parsed_response
    end
  end

  def delete
    response = self.class.delete("https://api.heroku.com/apps/#{@app_name}")
    return response.parsed_response if ok?(response)
  end

  private

  def ok?(response)
    (200..299).include? response.code
  end
end

class HTTParty::Response
  protected

  def ok?
    @response.code =~ /^2/
  end
end
