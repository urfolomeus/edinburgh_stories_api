class Asset < ActiveRecord::Base
  belongs_to :user

  def self.file_types
    ["image"]
  end

  validates :user, :title, :url, presence: true
  validates :file_type, inclusion: { in: Asset.file_types }
end

