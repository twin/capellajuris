# encoding:utf-8
require 'sinatra'
require 'haml'
require 'sass'
require 'compass'
require 'sequel'
require 'sqlite3'
require 'redcarpet'
require 'active_support/core_ext/string/inflections'
require 'active_support/inflections'
require 'active_support/core_ext/object/blank'
require 'extras/flickr'
require 'uri'
require 'bcrypt'

require_relative 'helpers'
require_relative 'extras/cro_dates'

# Haml & Sass/Compass
configure do
  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
    config.sass_dir = 'views/css'
    config.images_dir = 'public/images'
    config.line_comments = false
  end

  set :haml, { :format => :html5 }
  set :sass, Compass.sass_engine_options
end


# Sequel
DB = Sequel.sqlite 'db/databases/master.db'

module Sequel
  extension :pretty_table
  extension :migration

  class Model
    plugin :schema
    plugin :validation_helpers
  end
end

Dir['db/models/*'].each { |model| require_relative model }


# Sinatra
enable :sessions




# Application

get '/' do
  haml :index
end


post '/login' do
  authenticate! do
    log_in!
    redirect :/
  end
end

get '/logout' do
  log_out!
  redirect :/
end

get '/confirmation/:type/:id' do
  @type, @id = params[:type], params[:id]
  haml :confirmation
end


get '/content/new' do
  halt 404 if not logged_in?
  referrer = URI.parse(request.referrer) if request.referrer
  @content = Content.new(page: referrer.path)
  haml :'forms/content'
end

[:post, :put].each do |method|
  send(method, '/preview') do
    @text = params[:text]
    haml :preview
  end
end

post '/content/new' do
  Content.create(text: params[:text], type: 'content', page: params[:page])
  redirect params[:page]
end

get '/content/:id' do
  halt 404 if not logged_in?
  @content = Content[params[:id]]
  haml :'forms/content'
end

put '/content/:id' do
  Content[params[:id]].update(text: params[:text])
  redirect params[:page]
end

delete '/content/:id' do
  Content[params[:id]].destroy
  redirect back
end

get '/sidebar/:id' do
  halt 404 if not logged_in?
  @sidebar = Sidebar[params[:id]]
  haml :'forms/sidebar'
end

put '/sidebar/:id' do
  @sidebar = Sidebar[params[:id]].set(video_title: params[:video_title], video: params[:video],
                                      audio_title: params[:audio_title], audio: params[:audio])
  if @sidebar.valid?
    @sidebar.save
    redirect :/
  else
    haml :'forms/sidebar'
  end
end

get '/news/new' do
  halt 404 if not logged_in?
  @content = News.new
  haml :'forms/content'
end

post '/news/new' do
  News.create(text: params[:text], created_at: Date.today)
  redirect :/
end

get '/news/:id' do
  halt 404 if not logged_in?
  @content = News[params[:id]]
  haml :'forms/content'
end

put '/news/:id' do
  News[params[:id]].update(text: params[:text])
  redirect :/
end

delete '/news/:id' do
  News[params[:id]].delete
  redirect :/
end

get '/members' do
  haml :'forms/members'
end

post '/member/new' do
  Member.create(first_name: params[:first_name], last_name: params[:last_name], voice: params[:voice])
  haml :'forms/members'
end

delete '/member/:id' do
  Member[params[:id]].delete
  haml :'forms/members'
end


get '/:page' do
  haml params[:page].to_sym
end


get '/css/screen.css' do
  sass :'css/screen'
end


not_found do
  "A 'Not found' message here."
end
