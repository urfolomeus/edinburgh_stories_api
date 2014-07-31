class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.string   :title
      t.string   :file_type
      t.string   :url
      t.text     :description
      t.string   :year
      t.string   :month
      t.string   :day
      t.integer  :width
      t.integer  :height
      t.integer  :resolution
      t.string   :device
      t.float    :length
      t.boolean  :is_readable

      t.timestamps
    end
  end
end

