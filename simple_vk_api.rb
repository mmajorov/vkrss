require 'json'
require 'net/http'
require 'uri'


class SimpleVkApi
  def initialize(user)
    @user = user
  end
  
  def full_name
    @full_name ||= begin
      rawdata = request "users.get", user_ids: @user
      user = rawdata.first
      [user['first_name'], user['last_name']].join ' '
    end
  end
  
  def wall_posts
    @posts ||= begin
      rawdata = request "wall.get", domain: @user
      posts = rawdata
      posts.shift
      posts
    end
  end
  
  private
    def request(method, params)
      url = "http://api.vk.com/method/#{method}?#{URI.escape(params.collect{|k,v| "#{k}=#{v}"}.join('&'))}"
      uri = URI.parse(url) 
      http = Net::HTTP.new(uri.host, uri.port)
      begin
        request = Net::HTTP::Get.new(uri.request_uri)   
        response = http.request(request)      
        result = JSON.parse(response.body)
      rescue
        result = {'error' => {error_msg: 'Network Error'}}.to_json
      end
      raise "Vk Api Error" if result['error']
      
      result['response']
    end
end