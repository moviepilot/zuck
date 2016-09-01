# External requires.
require 'active_support/all'
require 'httparty'
require 'httmultiparty'

# Internal requires.
require 'zuck/base'
Dir[File.expand_path('../zuck/*.rb', __FILE__)].each { |f| require f }

module Zuck

  def self.host
    'https://graph.facebook.com/v2.6'
  end

  def self.access_token=(access_token)
    @access_token = access_token
  end

  def self.access_token
    @access_token
  end

end
