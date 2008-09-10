require 'rubygems'
gem 'rspec', '~> 1.1.3'
require 'spec'

# add library's lib directory
$:.unshift File.dirname(__FILE__) + '/../lib'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

def stub_response(name)
  File.open(File.dirname(__FILE__) + "/feeds/#{name}").read
end
