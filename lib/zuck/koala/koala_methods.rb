module Zuck
  module KoalaMethods

    # You can include this to any object that should have a `graph`
    # getter and setter that checks for {::Koala::Facebook::API}
    # instances with an access token.

    def graph=(g)
      validate_graph(g)
      @graph = g
    end

    def graph
      @graph
    end

    private

    def validate_graph(g)
      e = "#{g.class} is not a Koala::Facebook::API"
      raise e unless g.is_a? ::Koala::Facebook::API
      e = "#{g} does not work without an access_token"
      raise e unless g.access_token
    end

  end
end
