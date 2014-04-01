require 'sinatra'
require 'rss'
require './simple_vk_api'

get '/' do
  'Hello world!'
end

get '/:nickname' do
  nickname = 'michas'
  
  vk_api = SimpleVkApi.new nickname
  vk_user = vk_api.full_name
  vk_posts = vk_api.wall_posts
  
  rss = RSS::Maker.make("atom") do |maker|
    maker.channel.author = vk_user
    maker.channel.updated = Time.now.to_s
    maker.channel.about = "http://www.ruby-lang.org/en/feeds/news.rss"
    maker.channel.title = vk_user

    vk_posts.each do |post|
      maker.items.new_item do |item|
        item.link = "http://vk.com/"
        item.title = "vk.post"
        item.summary = post['text']
        item.updated = Time.now.to_s
      end
    end
  end
  rss.to_s
end