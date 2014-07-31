require 'sinatra'
set :environment, :test

require 'timecop'
require File.join(File.dirname(__FILE__), '../app.rb')

ActiveRecord::Base.logger = nil

RSpec.configure do |config|
  config.before(:each) do
    Asset.destroy_all
    User.destroy_all
  end
end
