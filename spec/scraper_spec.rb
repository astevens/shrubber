require 'spec_helper'

describe "AuctionScraper Model" do
  let(:login_config) {YAML.load_file(Padrino.root("config", "login.yml"))}
  let(:auction_scraper) { AuctionScraper.new(:username => login_config["username"], :password => login_config["password"]) }

  it 'can be created' do
    auction_scraper.should_not be_nil
  end

  it 'can login' do
    result = auction_scraper.login
    result.should_not be_nil
  end

  it "can extract auction id's from a listing page" do
    auction_scraper.login
    result = auction_scraper.extract_auctions(1)
    result.length.should == 20
  end

  it "can create a specific auction" do
    auction_scraper.login
    auction_id = auction_scraper.extract_auctions.last
    result = auction_scraper.get_auction(auction_id)
    result.should_not be_nil
    result.should be_a AuctionItem
    result.should be_valid
  end

  it "can find the number of listing pages" do
    auction_scraper.login
    result = auction_scraper.get_number_of_auctions
    result.should_not be_nil
    result.should > 0

    result = auction_scraper.get_number_of_pages
    result.should_not be_nil
    result.should > 0
  end

  it "can get multiple pages of auctions" do
    auction_scraper.login
    result = auction_scraper.get_all_auctions(1).count.should == 20
    result = auction_scraper.get_all_auctions(2).count.should == 40
  end

end
