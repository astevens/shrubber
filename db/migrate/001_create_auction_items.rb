migration 1, :create_auction_items do
  up do
    create_table :auction_items do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :auction_items
  end
end
