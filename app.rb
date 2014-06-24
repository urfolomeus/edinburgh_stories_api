require 'sinatra'
require 'json'
require 'couchrest_model'

ENV["COUCHDB_URL"] = "http://localhost:5984"
ENV["COUCHDB_DEFAULT_DB"] = "memphis_spoof_api"

configure do
  $COUCH = CouchRest.new ENV["COUCHDB_URL"]
  $COUCH.default_database = ENV["COUCHDB_DEFAULT_DB"]
  $COUCHDB = $COUCH.default_database
end

require File.expand_path('models/asset', File.dirname(__FILE__))

# ROOT

get '/' do
  erb :form
end


# ASSETS

get '/assets' do
  content_type :json
  Asset.all.to_json
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
