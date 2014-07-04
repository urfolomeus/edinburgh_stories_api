require 'sinatra'
require 'json'
require 'couchrest_model'

ENV["COUCHDB_URL"] ||= "http://localhost:5984"
ENV["COUCHDB_DEFAULT_DB"] = "memphis_spoof_api"

configure do
  $COUCH = CouchRest.new ENV["COUCHDB_URL"]
  $COUCH.default_database = ENV["COUCHDB_DEFAULT_DB"]
  $COUCHDB = $COUCH.default_database

  # HACK: https://github.com/couchrest/couchrest_model/issues/105
  if uri = URI.parse(ENV['COUCHDB_URL'])
    CouchRest::Model::Base.configure do |config|
      config.connection = {
        :protocol => uri.scheme,
        :host     => uri.host,
        :port     => uri.port,
        :prefix   => 'couchrest', # database name or prefix
        :suffix   => nil,
        :join     => '_',
        :username => uri.user,
        :password => uri.password
      }
    end
  end
end

require File.expand_path('models/asset', File.dirname(__FILE__))

# ROOT
get '/' do
  erb :form
end


# ASSETS

get '/assets' do
  content_type :json
  Asset.by_title.to_json
end

get '/assets/:id' do
  content_type :json
  Asset.find(params[:id]).to_json
end

post '/assets' do
  asset = Asset.create! params[:asset]
  content_type :json
  Asset.find(asset.id).to_json
end

put '/assets/:id' do
  asset = Asset.find(params[:id])
  asset.update_attributes(url: params[:asset][:url])
  asset.to_json
end
