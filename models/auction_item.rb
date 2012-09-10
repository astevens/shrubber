class AuctionItem
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :remote_key, Integer, :index => true
  property :name, String
  property :current_bid_price, Float
  property :buy_it_now_price, Float
  property :shipping_cost, Float
  property :end_time, DateTime
  property :quantity, Integer
  property :location, String
  property :manufacturer, String
  property :model_number, String
  property :items_included, String
  property :items_missing, String
  property :condition, String
  property :finalized, Boolean, :default => false, :index => true

  belongs_to :category

end
