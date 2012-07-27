require 'spec_helper'

describe FbAds::TargetingSpec do
  let(:user){ FactoryGirl.create :user }
  let(:reach_response){ {
    "users" => 23688420,
    "bid_estimations" => [
      {
        "location" => 3,
        "cpc_min" => 37,
        "cpc_median" => 44,
        "cpc_max" => 57,
        "cpm_min" => 6,
        "cpm_median" => 12,
        "cpm_max" => 33
      }
    ],
    "imp_estimates" => [
    ],
    "data" => {
      "users" => 23688420,
      "bid_estimations" => [
        {
          "location" => 3,
          "cpc_min" => 37,
          "cpc_median" => 44,
          "cpc_max" => 57,
          "cpm_min" => 6,
          "cpm_median" => 12,
          "cpm_max" => 33
        }
      ],
      "imp_estimates" => [
      ]
    }
  }}


  before(:each) do
    @graph_mock = mock('koala')
    user.should_receive(:get_graph).any_number_of_times.and_return @graph_mock
  end

  describe "validating keywords" do

    let(:valid_keyword_result){   [{"valid" => true }] }
    let(:invalid_keyword_result){ [{"valid" => false }] }

    it "escapes commas" do
      o = {type: 'adkeywordvalid', keyword_list: 'foo%2Cbar' }
      @graph_mock.should_receive(:search).with(nil, o).and_return []
      fts = FbAds::TargetingSpec.new(user)
      fts.validate_keyword('foo,bar').should == false
    end

    it "acknowledges valid keywords" do
      o = {type: 'adkeywordvalid', keyword_list: 'foo' }
      @graph_mock.should_receive(:search).with(nil, o).and_return valid_keyword_result
      fts = FbAds::TargetingSpec.new(user)

      fts.validate_keyword('foo').should == true
    end

    it "refuses invalid keywords" do
      o = {type: 'adkeywordvalid', keyword_list: 'foo' }
      @graph_mock.should_receive(:search).with(nil, o).and_return invalid_keyword_result
      fts = FbAds::TargetingSpec.new(user)

      fts.validate_keyword('foo').should == false
    end
  end

  describe "options given in spec" do
    it "accepts male as gender" do
      expect{
        FbAds::TargetingSpec.new(user, countries: ['US'], keywords: ['foo'], gender: 'male')
      }.to_not raise_error
    end

    it "accepts without gender" do
      expect{
        FbAds::TargetingSpec.new(user, countries: ['US'], keywords: ['foo'])
      }.to_not raise_error
    end

    it "accepts single keywrod" do
      expect{
        FbAds::TargetingSpec.new(user, countries: ['US'], keyword: 'foo')
      }.to_not raise_error
    end

    it "does not accept invalid genders" do
      expect{
        FbAds::TargetingSpec.new(user, countries: ['US'], keywords: ['foo'], gender: 'gemale')
      }.to raise_error("Gender can only be male or female")
    end
  end

  describe "fetching the reach from facebook" do
    it "asks koala for the right thing" do
      ts = FbAds::TargetingSpec.new(user)
      ts.should_receive(:validate_keyword).with('foo').and_return true
      expected_spec = { targeting_spec: "{\"countries\":[\"US\"],\"keywords\":[\"foo\"],\"age_min\":13,\"connections\":[]}" }
      @graph_mock.should_receive(:get_object).with("#{user.ad_account}/reachestimate", expected_spec)
                .and_return(reach_response)

      ts.spec = {countries: ['US'], keywords: 'foo'}
      ts.fetch_reach.should_not == false
    end
  end

end
