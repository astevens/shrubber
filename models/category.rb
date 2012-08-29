class Category
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String, :required => true

  has n, :auction_items

  is :tree, :order => :name

end
