class Color < ActiveRecord::Base
  belongs_to :size
  has_many :textures, dependent: :destroy
end
