Gem::Specification.new do |spec|
  spec.author = 'Elise Huard'
  spec.email = 'mediafeed@elisehuard.be'
  spec.homepage = 'http://github.com/elisehuard/media_feed'

  spec.name = 'media_feed'
  spec.version = '0.0.2'
  spec.date = "11-09-2008"

  spec.has_rdoc = true
  #spec.platform = “Gem::Platform::Ruby”
  spec.summary = 'Gem to easily extract information out of a media feed'
  spec.require_path = ["lib"]
  spec.files = ['lib/media_feed.rb']
  spec.test_files = ['spec/media_feed_spec.rb',
                     'spec/spec_helper.rb',
                     'spec/feeds/ChrisPirilloShow',
                     'spec/feeds/NASAcast_vodcast',
                     'spec/feeds/tedtalks_video',
                     'spec/feeds/diggnation']
  spec.add_dependency('libxml-ruby',["> 0.0.0"]) 
end
