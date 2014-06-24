class Asset < CouchRest::Model::Base
  use_database $COUCHDB

  property :name,         String
  property :file_type,    String
  property :url,          String
  property :alt,          String
  property :description,  String
  property :width,        Integer
  property :height,       Integer
  property :resolution,   Integer
  property :device,       String
  property :length,       Float
  property :is_readable,  TrueClass, default: false

  timestamps!

  design do
    view :by_name
  end
end

