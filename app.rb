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

  def token
    @token ||= env['HTTP_AUTHORIZATION'].match(/^Token token=\"([^\"]*)\"$/)[1]
  rescue
    halt(400, {'Content-Type' => 'json'}, {error: "Invalid token"}.to_json)
  end

  def current_user
    @current_user ||= User.find_by_auth_token(token) || halt(404)
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
  rescue InvalidCredentials => ice
    halt 403, { error: ice }.to_json
  rescue Exception => e
    halt 500, { error: e }.to_json
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

get '/assets/user' do
  content_type :json
  current_user.assets.to_json
end

get '/assets/:id' do
  content_type :json
  asset.to_json
end

post '/assets' do
  asset = current_user.assets.create! asset_attrs(params[:asset])
  content_type :json
  Asset.find(asset.id).to_json
end

def asset_attrs(attrs)
  attrs.select{|k,v| Asset.new.attributes.keys.member?(k.to_s)}
end

put '/assets/:id' do
  asset.update_attributes(url: params[:asset][:url])
  asset.to_json
end

