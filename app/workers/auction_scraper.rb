class AuctionScraper
  attr_accessor :username, :password, :session

  def initialize(options = {})
    self.username = options[:username]
    self.password = options[:password]
    self.session = Mechanize.new
  end

  def login
    page = session.get("https://bestbuy.dtdeals.com/auction/index.cfm")
    login_form = page.form_with(:action => "https://bestbuy.dtdeals.com/auction/index.cfm")
    login_form.login_name = username
    login_form.login_password = password

    page = login_form.submit

    error_message = page.at("form div div span:last-child")
    if error_message.present? && error_message.text == "Login failed."
      throw "Login failure"
    end

    page
  end

  def extract_auctions(page_number = 1)
    page = session.get("http://bestbuy.dtdeals.com/auction/index.cfm?P=4&pageno=#{page_number}&itemtype=3&searchtype=1&as=0")
    links = page.search("div.tabular-cell.col-title a")
    links.map{|l| l.attributes["href"].value.match(/I=(\d+)/)[1]}
  end

  def get_all_auctions(number_of_pages = nil)
    auction_ids = []
    number_of_pages ||= get_number_of_pages
    number_of_pages.times do |page_number|
      auction_ids = auction_ids + extract_auctions(page_number + 1)
    end
    auction_ids
  end

  def get_auction(auction_id)
    auction = AuctionItem.first_or_new(:remote_key => auction_id)
    auction_url = "http://bestbuy.dtdeals.com/auction/index.cfm?P=5&I=#{auction_id}"
    logger.debug auction_url
    page = session.get(auction_url)

    category_list = page.search("div#breadCrumbs a").map(&:text)
    if category_list.length > 0
      auction.category = find_category(category_list)
    end

    name_element = page.at("div.ItemTitle")
    # sometimes an auction gets deleted or something
    unless name_element.present?
      logger.warn "Couldn't load auction #{auction_url}"
      return nil
    end

    manufacturer = page.at("table table table table tr td").text.match(/Manufacturer: (.+)/)[1]
    # some old fashined string handling since I don't seem to be able to regex part of a word
    manufacturer = manufacturer[0..(manufacturer.index("Model") - 1)]
    model_number = page.at("table table table table tr td").text.match(/Model Number: (.+)/)[1]
    model_number = model_number[0..(model_number.index("Items") - 1)]

    auction.attributes = {
      :name => name_element.children[2].text.strip,
      :current_bid_price => page.at("table.grad_box td[valign=top] span").text[1..-1].to_f,
      :end_time => DateTime.strptime(page.at("table.grad_box tr td[nowrap] font[color='#666666']").text.strip, "%m/%d/%y %I:%M:%S %p Central Standard Time"),
      :manufacturer => manufacturer,
      :model_number => model_number,
      :quantity => page.form_with(:action => "index.cfm").bidquantity.to_i,
      :location => page.at("table table table table tr td+td").text.match(/Item Location: (.+)/)[1],
      :items_included => "example",
      :items_missing => "example",
      :condition => "stuff"
    }
    # shipping is optional and not rendered if not present
    shipping_cost = page.at("table.grad_box tr td font strong span")
    if shipping_cost.present?
      auction.shipping_cost = shipping_cost.text[1..-1].to_f
    end

    buy_it_now_form = page.form_with(:action => "index.cfm")
    if buy_it_now_form.present?
      auction.buy_it_now_price = buy_it_now_form.maxbid.to_f
    end

    auction
  end

  def find_category(category_names)
    category = nil
    category_names.each do |category_name|
      category = Category.first_or_create(:name => category_name, :parent_id => category ? category.id : nil)
    end
    category
  end

  def get_number_of_auctions
    page = session.get("http://bestbuy.dtdeals.com/auction/index.cfm?P=4&catlvl=0&catid=0&itemtype=3")
    page.at("div.pagenav").text.strip.match(/^(\d+)/)[1].to_i
  end

  def get_number_of_pages
    (get_number_of_auctions / 20).ceil
  end

end