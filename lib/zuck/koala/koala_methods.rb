# You can include this to any object that should have a `graph`
# getter and setter that checks for {::Koala::Facebook::API}
# instances with an access token.
module Zuck
  module KoalaMethods

    def graph=(g)
      raise "#{g.class} is not a Koala::Facebook::API" unless g.is_a? ::Koala::Facebook::API
      raise "#{g} does not work without an access_token" unless g.access_token
      @graph = g
    end

    def graph
      @graph
    end

  end
end
