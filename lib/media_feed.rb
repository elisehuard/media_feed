=begin rdoc
The media_feed library parses a media rss stream and stores the information in its attributes.
== Examples:
Fetch a whole feed
    media_feed = MediaFeed::Feed.new('http://www.nasa.gov/rss/NASAcast_vodcast.rss ')
    media_feed.fetch
Fetch starting at a certain date (date must be in RFC2822 format - use Time.rfc2822)
    media_feed = MediaFeed::Feed.new('http://www.nasa.gov/rss/NASAcast_vodcast.rss ')
    media_feed.fetch_since("Wed, 10 Sep 2008 10:29:18 +0200")
Use the retrieved information
    thumbnail = media_feed.thumbnail
    media_feed.items.each do |item|
      ...
    end
=end

require 'rubygems'
require 'open-uri'
require 'libxml'

module MediaFeed
# Exception for an invalid URL format
class InvalidUrl < Exception
end

# Exception for an invalid Item
class InvalidMediaItem < Exception
end

# Exception for if feed url returns an empty result or a HTTP error
class FeedNotFound < Exception
end

# Exception for invalid xml
class InvalidXML < Exception
end

# Exception when receiving an invalid date (non-RFC2822) for input
class InvalidDate < Exception
end

# Mediafeeds handles the retrieval of feed information.  The feed attributes are stored
# in feed attributes, and the individual items are stored in an array of Item objects.
class Feed
  include(LibXML)
  
  MEDIA_RSS_NAMESPACE = 'media:http://search.yahoo.com/mrss'
  
  attr_reader :title, :description, :thumbnail, :pubDate, :items

  # Feed is initialized with a valid url for the feed itself.
  def initialize(url)
    raise ArgumentException if url.nil?
    raise InvalidUrl if url !~ /(^(http|https):\/\/[a-z0-9]+([-.]{1}[a-z0-9]*)+. [a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
    @url = url
    @entries = nil
  end
  
  # fetch the whole media feed
  def fetch
    doc = get_feed
    return nil if doc.nil?
    parse_feed(doc)
  end
  
  # fetch all entries of the media feed since a certain date (RFC2822 format).
  def fetch_since(last_date)
    @last_date = parse_date(last_date)
    fetch
  end
  
  def to_s
    "title #{@title}, description #{@description}" +
    @items.inject('') do |str,item|
      str + entry.to_s
    end
  end
  
private
  
  def get_feed
    response = ''
    open(@url){ |f|
      # Save the response body
      response = f.read
    }    
    raise FeedNotFound if response.nil? || response.empty?
    response
  rescue OpenURI::HTTPError
    raise FeedNotFound
  end
  
  # for some strange reason, the xml parsing by libxml stumbles over & symbols.  cute.
  def preprocess(doc)
    doc.gsub!(/&/,'&amp;')
    doc
  end
  
  def parse_feed(doc)
    all_nodes = parse_document(preprocess(doc))
    channel = all_nodes[0]
    @title = content(channel,'title')
    @description = content(channel,'description')
    @thumbnail = content(channel,'image/url') || content(channel,'media:thumbnail')
    @pubDate = content(channel,'pubDate')
    if @pubDate && @last_date
      feed_pub_date = parse_date(@pubDate)
      return if feed_pub_date == @last_date
    end
    items = channel.find('//item')

    item_pubDate = nil # latest item date
    @items = items.inject([]) do |result,node|
      item = parse_item(node)
      if !item.valid? # invalid items shouldn't be added to feed but shouldn't stop the rest of the feed
        puts "Faulty item in the feed - not loaded : "
        puts item.to_s
      else
        result << item if item.is_after?(@last_date)
        item_pubDate = item.pubDate if !item.pubDate.nil? && (item_pubDate.nil? || item.pubDate > item_pubDate)
      end
      result
    end
    @pubDate = item_pubDate if @pubDate.nil?
  end

  def parse_document(doc)
    parser = LibXML::XML::Parser.new
    parser.string = doc
    xml = parser.parse
    root = xml.root
    root.find('*')
  rescue
    raise InvalidXML
  end
  
  def parse_item(node)
    item = Item.new
    item.title = content(node,'title')
    item.description = content(node,'description')
    item.link = content(node,'link')
    item.enclosure = url(node,'enclosure') || url(node,'media:content') || content(node,'guid')
    date = content(node,'pubDate')
    item.pubDate = parse_date(date) if date && !date.empty?
    item.thumbnail = content(node,'image/url') || content(node,'media:thumbnail')
    keywords = content(node,'media:keywords')
    item.keywords = keywords.gsub(/ */,'').split(',') if keywords
    
    # pubDate if not filled in by feed -> first (valid) one is probably most recent
    @pubDate = item.pubDate.rfc2822 if @pubDate.nil? && item.pubDate
    item
  end

  def content(parent_node,xpath)
    result_xpath = parent_node.find(xpath,MEDIA_RSS_NAMESPACE)
    result_xpath[0].content if result_xpath && result_xpath[0]
  end
  
  def url(parent_node,xpath)
    result_xpath = parent_node.find(xpath,MEDIA_RSS_NAMESPACE)
    result_xpath[0]['url'] if result_xpath && result_xpath[0]
  end
  
  # date string should be in rfc2822 format ex. Sat, 06 Sep 2008 11:59:15 +0000
  def parse_date(date_string)
    time = Time.rfc2822(date_string)
  rescue => e
    raise InvalidDate
  end
  
end

class Item
  attr_accessor :title, :description, :link, :pubDate, :enclosure, :thumbnail, :keywords
  
  def valid?
    if title.nil? || link.nil? || enclosure.nil?
      false
    else
      true
    end
  end
  
  def is_after?(last_date)
    (last_date.nil? || pubDate.nil? || (pubDate > last_date))
  end
  
  def to_s
    "title #{title}\n" + 
    "description #{description}\n" +
    "link #{link}\n" +
    "enclosure #{enclosure}\n" +
    "pubDate #{pubDate}\n"
  end
  
end
end
