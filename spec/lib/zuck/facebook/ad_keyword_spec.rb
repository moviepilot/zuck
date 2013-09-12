require 'spec_helper'

describe Zuck::AdKeyword do
  let(:graph){ Koala::Facebook::API.new(test_access_token)}

  it "finds the best keyword with a #" do
    VCR.use_cassette('ad_keyword_search_disney') do
      Zuck::AdKeyword.best_guess(graph, 'disney')[:keyword].should == '#The Walt Disney Company'
    end
  end

  it "finds the best keyword when no keyword with # is available" do
    VCR.use_cassette('ad_keyword_search_moviepilot') do
      Zuck::AdKeyword.best_guess(graph, 'moviepilot')[:keyword].should == 'Moviepilot'
    end
  end

  it "returns nil when nothing could be found" do
    VCR.use_cassette('ad_keyword_search_nonexistant') do
      Zuck::AdKeyword.best_guess(graph, 'ick spickeby').should be_nil
    end
  end
end
