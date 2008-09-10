require File.dirname(__FILE__) + '/spec_helper'
require 'media_feed'

describe MediaFeed::Feed, '.initialize' do
  it 'should be initialized using an url' do
    feed = MediaFeed::Feed.new('http://homepage.mac.com/vi_fimagazine/podcast.xml')
    feed.should_not be_nil
  end
  
  it 'should raise an error when no url is given' do
    lambda {
      feed = MediaFeed::Feed.new(nil)
    }.should raise_error
  end
  
  it 'should raise an error when an invalid url is given' do
    lambda {
      feed = MediaFeed::Feed.new('check out this invalid url')
    }.should raise_error(MediaFeed::InvalidUrl)
  end
 
end

describe MediaFeed::Feed, '.fetch' do
  it 'should raise an error when the url is unreachable at fetch' do
    lambda {
      feed = MediaFeed::Feed.new('http://never.findthis.com/videofeed.xml')
      feed.fetch
    }.should raise_error(MediaFeed::InvalidXML)
  end
  
  it 'should fetch valid items from video feed TED talks' do
    lambda {
      feed = MediaFeed::Feed.new('http://feeds.feedburner.com/tedtalks_video')
      feed.stubs(:get_feed).returns(stub_response('tedtalks_video'))
      feed.fetch
      feed.items.should_not be_nil
      feed.items.should have_at_least(1).items
    }.should_not raise_error
  end
  
  it 'should fetch valid items from video feed NASA' do
    lambda {
      feed = MediaFeed::Feed.new('http://www.nasa.gov/rss/NASAcast_vodcast')
      feed.stubs(:get_feed).returns(stub_response('NASAcast_vodcast'))
      feed.fetch
      feed.items.should_not be_nil
      feed.items.should have_at_least(1).items
    }.should_not raise_error
  end
  
  it 'should fetch valid items from video feed Diggnation' do
    lambda {
      feed = MediaFeed::Feed.new('http://revision3.com/diggnation/feed/quicktime-large/')
      feed.stubs(:get_feed).returns(stub_response('diggnation'))
      feed.fetch
      feed.items.should_not be_nil
      feed.items.should have_at_least(1).items
    }.should_not raise_error
  end

end

describe MediaFeed::Feed, '.fetch_since' do
  
  it 'should not work with invalid last date' do
    feed = MediaFeed::Feed.new('http://www.green.tv/!video.feed.rss/highlights')
    lambda {
      feed.fetch_since('no date here')
    }.should raise_error(MediaFeed::InvalidDate)
  end
  
  it 'should raise an error with no date' do
    feed = MediaFeed::Feed.new('http://www.green.tv/!video.feed.rss/highlights')
    lambda {
      feed.fetch_since(nil)
    }.should raise_error(MediaFeed::InvalidDate)    
  end
  
  it 'should not fetch items if no new ones since last date' do
    feed = MediaFeed::Feed.new('http://feeds.feedburner.com/tedtalks_video')
    feed.stubs(:get_feed).returns(stub_response('tedtalks_video'))
    feed.fetch
    date = feed.pubDate
    feed2 = MediaFeed::Feed.new('http://feeds.feedburner.com/tedtalks_video')
    feed.stubs(:get_feed).returns(stub_response('tedtalks_video'))
    feed2.fetch_since(date)
    feed2.items.should be_nil
  end
  
  it 'should only fetch the items that are new since last fetch if last date is given' do
    feed = MediaFeed::Feed.new('http://feeds.pirillo.com/ChrisPirilloShow')
    feed.stubs(:get_feed).returns(stub_response('ChrisPirilloShow'))
    feed.fetch_since('Sat, 06 Sep 2008 11:59:15 +0000')
    feed.items.should have(6).items
  end
  
  it 'should work when no new ones and pubDate' do
    feed = MediaFeed::Feed.new('http://www.nasa.gov/rss/NASAcast_vodcast.rss ')
    feed.stubs(:get_feed).returns(stub_response('NASAcast_vodcast'))
    feed.fetch_since("Fri, 05 Sep 2008 18:00:00 +0200")
    feed.items.should have(2).items
  end
  
end