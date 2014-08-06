class AddAttributionToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :attribution, :string
  end
end
