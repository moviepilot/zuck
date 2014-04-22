require 'spec_helper'

describe Zuck::AdInterest do
  let(:graph){ Koala::Facebook::API.new('CAAEvJ5vzhl8BAPGZCZCPL4FxryEHXGxPCuCGeqe3PEWIjhIvJ00HB8PPpokFmUkemvmEUHirqdNMc7zIDLSTVnX6jTQjAgSlzcYrAYJRQ32fr6RM5ZAnKPdgFEwN5tgvswatXZAI4vu7ZBAQexRl9MU0CpwW7JDDBZAGo5XDrCKrBxkUUWJUvh')}

  it "finds the best interest with a #" do
    VCR.use_cassette('ad_interest_search_disney') do
      Zuck::AdInterest.best_guess(graph, 'disney')[:interest].should == 'The Walt Disney Company'
    end
  end

  it "finds the best interest when no keyword with # is available" do
    VCR.use_cassette('ad_interest_search_moviepilot') do
      Zuck::AdInterest.best_guess(graph, 'moviepilot')[:interest].should == 'moviepilotcom'
    end
  end

  it "returns nil when nothing could be found" do
    VCR.use_cassette('ad_interest_search_nonexistant') do
      Zuck::AdInterest.best_guess(graph, 'ick spickeby').should be_nil
    end
  end
end
