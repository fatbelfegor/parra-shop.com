class Prsize < ActiveRecord::Base
  belongs_to :product
  has_many :prcolors
  has_many :proptions
end
