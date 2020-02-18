# require 'factory_girl'
# require "faker"
# require 'timecop'
# require 'webmock/rspec'
require 'faraday'
require 'json'
require 'active_support/all'
require 'uri'
require "mini_magick"
require 'redis'

Dir[File.dirname(__FILE__) + "/**/shared_examples/*.rb"].each {|file| require file }


RSpec.configure do |config|
  # disable warnings
  config.warnings = false

  config.filter_run_when_matching :focus

  # Use color in STDOUT
  config.color = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :progress #:documentation, :progress, :html, :textmate

  config.fail_fast

end

def valid_url?(url)
  uri = URI.parse(url)
  uri.is_a?(URI::HTTP) && !uri.host.nil?
rescue URI::InvalidURIError
  false
end

def execute_samples_using(shared_examples)
  describe shared_examples do
    Dir.glob('./samples/*').grep(/^((?!_as)(?!failures).)*$/).select {|f| File.directory? f}.each do | directory |
      ext = directory.split("./samples/")[1]
      Dir["#{directory}/*.#{ext}"].each do |file|
        sleep((File.size(file) / 10.0**8)/3)
        it_should_behave_like shared_examples, ext, file, nil
      end
    end
  end
end
