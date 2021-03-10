ENV['RUBY_ENV'] = 'test'
$LOAD_PATH << './'

require 'rspec/its'
require 'webmock/rspec'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
