require 'spec_helper'

describe Zuck::AdKeyword do
  let(:graph){ Koala::Facebook::API.new('CAAEvJ5vzhl8BAE7m0kztNbbASKHymRlXoBZCdZCtMsebNEgaR0yOmZCBfeTIXT8MnuV3ZCH5lBDQOcC4S9geswWZBuF707gJ42lV9DHgGILsRaiG2upipiHggl7UZAeDVgBSSsap9s9uv1ghZCxNsmH')}

  it "finds the best keyword with a #" do
    VCR.use_cassette('ad_keyword_search_disney') do
      Zuck::AdKeyword.best_guess(graph, 'disney')[:keyword].should == '#The Walt Disney Company'
    end
  end

  it "finds the best keyword when no keyword with # is available" do
    VCR.use_cassette('ad_keyword_search_steve_carell') do
      Zuck::AdKeyword.best_guess(graph, 'steve carell')[:keyword].should == 'Steve Carell'
    end
  end

  it "returns nil when nothing could be found" do
    VCR.use_cassette('ad_keyword_search_nonexistant') do
      Zuck::AdKeyword.best_guess(graph, 'ick spickeby').should be_nil
    end
  end
end
