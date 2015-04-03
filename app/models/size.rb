class Size < ActiveRecord::Base
  belongs_to :product
  has_many :colors
  has_many :options
end
