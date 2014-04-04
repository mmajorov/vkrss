require 'json'
require 'net/http'
require 'uri'


class SimpleVkApi
  def initialize(user)
    @user = user
  end
  
  def full_name
    @full_name ||= [user_info['first_name'], user_info['last_name']].join ' '
  end
  
  def wall_posts
    @posts ||= begin
      rawdata = request "wall.get", domain: @user
      posts = rawdata
      posts.shift #first element is counter
      posts
    end
  end
  
  def url_for_wall(post)
    "http://vk.com/#{@user}?w=wall#{user_info['uid']}_#{post['id']}"
  end

  def wall_url
    "http://vk.com/#{@user}"  
  end
  
  private
    def user_info
      @user_info ||= begin
        rawdata = request "users.get", user_ids: @user
        rawdata.first    
      end
    end
    
    def request(method, params)
      url = "http://api.vk.com/method/#{method}?#{URI.escape(params.collect{|k,v| "#{k}=#{v}"}.join('&'))}"
      uri = URI.parse(url) 
      http = Net::HTTP.new(uri.host, uri.port)
      begin
        request = Net::HTTP::Get.new(uri.request_uri)   
        response = http.request(request)      
        result = JSON.parse(response.body)
      rescue
        result = {'error' => {error_msg: 'Network Error'}}
      end
      raise "Vk Api Error" if result['error']
      
      result['response']
    end
end