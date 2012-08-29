require 'spec_helper'

describe "AuctionItem Model" do
  let(:auction_item) { AuctionItem.new }
  it 'can be created' do
    auction_item.should_not be_nil
  end
end
