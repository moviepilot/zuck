require 'spec_helper'

describe Zuck::AdInterest do
  let(:graph){ Koala::Facebook::API.new(test_access_token)}

  it "finds the best interest with a #" do
    VCR.use_cassette('ad_interest_search_disney') do
      Zuck::AdInterest.best_guess(graph, 'disney')[:name].should == 'The Walt Disney Company'
    end
  end

  it "finds the best interest when no keyword with # is available" do
    VCR.use_cassette('ad_interest_search_moviepilot') do
      Zuck::AdInterest.best_guess(graph, 'moviepilot')[:name].should == 'moviepilotcom'
    end
  end

  it "returns nil when nothing could be found" do
    VCR.use_cassette('ad_interest_search_nonexistant') do
      Zuck::AdInterest.best_guess(graph, 'ick spickeby').should be_nil
    end
  end
end
