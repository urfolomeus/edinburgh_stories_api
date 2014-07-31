require 'sinatra'
require 'json'
require 'rubygems'
require "sinatra/activerecord"

require File.expand_path('models/asset', File.dirname(__FILE__))
require File.expand_path('models/user', File.dirname(__FILE__))

I18n.enforce_available_locales = false

helpers do
  def asset
    @asset ||= Asset.find(params[:id]) || halt(404)
  end

  def current_user
    @current_user ||= User.get_with_token(params[:token]) || halt(404)
  end
end

# ROOT
get '/' do
  erb :form
end

# AUTHENTICATION
post '/signup' do
  user = User.new(params['user'])
  halt 400 unless user.save
end

post '/login' do
  begin
    user = User.authenticate!(params[:username], params[:password])
    user.login!
    content_type :json
    { token: user.auth_token }.to_json
  rescue InvalidCredentials
    halt 403
  end
end

post '/logout' do
  current_user.logout!
  halt 500 if current_user.logged_in?
end

# USERS

get '/users' do
  content_type :json
  User.all.to_json
end

# ASSETS

get '/assets' do
  content_type :json
  Asset.all.to_json
end

get '/assets/:id' do
  content_type :json
  asset.to_json
end

post '/assets' do
  asset = Asset.create! params[:asset]
  content_type :json
  Asset.find(asset.id).to_json
end

put '/assets/:id' do
  asset.update_attributes(url: params[:asset][:url])
  asset.to_json
end

