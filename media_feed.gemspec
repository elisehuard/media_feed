Gem::Specification.new do |spec|
  spec.author = 'Elise Huard'
  spec.email = 'mediafeed@elisehuard.be'
  spec.homepage = 'http://github.com/elisehuard/media_feed/tree/master'
  spec.name = 'media_feed'
  spec.version = '0.0.1'
  spec.has_rdoc = true
  #spec.platform = “Gem::Platform::Ruby”
  spec.summary = 'Gem to easily extract information out of a media feed'
  spec.require_path = ["lib"]
  spec.files = Dir['lib/**/*.rb','spec/**/*.rb','spec/feeds/*']
  spec.add_dependency('libxml-ruby')
end
