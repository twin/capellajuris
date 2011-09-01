# encoding:utf-8
require 'sinatra'
require_relative 'config'

get '/create' do
  redirect :index
end

get '/' do
  haml :index
end

get '/:page' do
  haml params[:page].to_sym
end


before '/login' do
  authenticate!
end

post '/login' do
  log_in!
end

after '/login' do
  redirect :index
end


post '/logout' do
  log_out!
end

after '/logout' do
  redirect back
end


before '/user' do
  redirect :index if params[:action] == 'Odustani'
  authenticate!
end

put '/user' do
  User.first.update(:username => params[:new_username], :password => params[:new_password])
end

after '/user' do
  redirect :index
end


get '/post/new' do
  if logged_in?
    session[:post] = Post.new
    haml :post
  end
end

get '/post/:id' do
  if logged_in?
    session[:post] = Post[params[:id]]
    haml :post
  end
end


before '/edit_post/:id' do
  redirect :index if params[:action] == 'Odustani'
  validate_post!
end

post '/edit_post/:id' do
  unless params[:id] == 'new'
    Post[params[:id]].update(:title => params[:title], :subtitle => params[:subtitle], :body => params[:body])
  else
    Post.create(:title => params[:title], :subtitle => params[:subtitle], :body => params[:body], :created_at => Date.today)
  end
end

after '/edit_post/:id' do
  session[:error] = session[:post] = nil
  redirect :index
end


delete '/delete_post/:id' do
  Post[params[:id]].delete
end

after '/delete_post/:id' do
  redirect :index
end


get '/content/new' do
  if logged_in?
    session[:content] = Content.new
    haml :content
  end
end

get '/content/:id' do
  if logged_in?
    session[:content] = Content[params[:id]]
    haml :content
  end
end


before '/edit_content/:id' do
  redirect :index if params[:action] == 'Odustani'
  validate_content!
end

post '/edit_content/:id' do
  unless params[:id] == 'new'
    Content[params[:id]].update(:title => params[:title], :body => params[:body])
  else
    Content.create(:title => params[:title], :body => params[:body])
  end
end

after '/edit_content/:id' do
  session[:error] = session[:content] = nil
  redirect :index if params[:id] == '1'
  redirect :o_nama
end


delete '/delete_content/:id' do
  Content[params[:id]].delete
end

after '/delete_content/:id' do
  redirect :o_nama
end


get '/css/screen.css' do
  sass :'css/screen'
end
