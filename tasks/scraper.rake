desc "runs the thing"
task :scrape => :environment do
  login_config = YAML.load_file(Padrino.root("config", "login.yml"))
  scraper =AuctionScraper.new(:username => login_config["username"], :password => login_config["password"])
  scraper.login
  scraper.get_all_auctions.each do |auction_id|
    scraper.get_auction(auction_id).save
  end

end

desc "gets final auction info"
task :final_updates do
  # clean up any leftovers
  AuctionItem.all(:end_time.lt => 2.hours.ago, :finalized => false).destroy

  auctions = AuctionItem.all(:end_time.lt => DateTime.now, :finalized => false)
  if auctions.count > 0
    login_config = YAML.load_file(Padrino.root("config", "login.yml"))
    scraper =AuctionScraper.new(:username => login_config["username"], :password => login_config["password"])
    scraper.login
    auctions = auctions.map do |auction|
      auction = scraper.get_auction(auction.remote_key)
      next unless auction.present?
      auction.finalized = true
      auction.save
    end
  end

end