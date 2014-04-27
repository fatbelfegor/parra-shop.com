class Prcolor < ActiveRecord::Base
  belongs_to :product
  has_many :textures
end
