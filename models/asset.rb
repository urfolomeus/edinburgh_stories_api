class Asset < CouchRest::Model::Base
  use_database $COUCHDB

  property :title,        String
  property :file_type,    String
  property :url,          String
  property :description,  String
  property :date,         Date
  property :year,         String
  property :month,        String
  property :day,          String
  property :width,        Integer
  property :height,       Integer
  property :resolution,   Integer
  property :device,       String
  property :length,       Float
  property :is_readable,  TrueClass, default: false

  timestamps!

  design do
    view :by_title
  end

  def fix_dates
    return unless date
    self.year  = date.year
    self.month = date.month
    self.day   = date.day
  end
end

