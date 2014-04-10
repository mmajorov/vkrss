require 'sinatra'
require 'rss'
require './simple_vk_api'

get '/' do
  haml :index
end

post '/' do
  return haml :index unless params[:nickname]
  redirect to("/#{params[:nickname]}")
end

get '/:nickname' do
  nickname = params[:nickname]
  
  vk_api = SimpleVkApi.new nickname
  vk_user = vk_api.full_name
  vk_posts = vk_api.wall_posts
  
  rss = RSS::Maker.make("atom") do |maker|
    maker.channel.author = vk_user
    maker.channel.updated = Time.at(vk_posts.first['date'].to_i).to_s
    maker.channel.about = vk_api.wall_url
    maker.channel.title = vk_user

    vk_posts.each do |post|
      maker.items.new_item do |item|
        item.id = post['id'].to_s
        item.link = vk_api.url_for_wall(post)
        item.title = "#{post['text'][0..19]}..."
        item.summary = post['text']
        item.updated = Time.at(post['date'].to_i).to_s
      end
    end
  end
  rss.to_s
end