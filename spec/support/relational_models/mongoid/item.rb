class Item
  include ::Mongoid::Document

  belongs_to :cart
end