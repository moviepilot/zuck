require 'spec_helper'

describe Zuck::TargetingSpec do
  let(:ad_account){ "2ijdsfoij" }
  let(:graph){ mock('koala') }
  let(:reach_response){ {         # These can probably go since we have
    "users" => 23688420,          # vcr cassetes with http requests and
    "bid_estimations" => [        # responses in place
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


  describe "validating keywords" do

    let(:valid_keyword_result){   [{"name" => "foo", "valid" => true }] }
    let(:invalid_keyword_result){ [{"name" => "sdjf", "valid" => false }] }

    it "escapes commas" do
      o = {type: 'adkeywordvalid', keyword_list: 'foo%2Cbar' }
      graph.should_receive(:search).with(nil, o).and_return []
      fts = Zuck::TargetingSpec.new(graph, ad_account, keywords: 'foo,bar')
      fts.validate_keyword('foo,bar').should == false
    end

    it "acknowledges valid keywords" do
      o = {type: 'adkeywordvalid', keyword_list: 'foo' }
      graph.should_receive(:search).with(nil, o).and_return valid_keyword_result
      fts = Zuck::TargetingSpec.new(graph, ad_account)

      fts.validate_keyword('foo').should == true
    end

    it "refuses invalid keywords" do
      o = {type: 'adkeywordvalid', keyword_list: 'sdjf' }
      graph.should_receive(:search).with(nil, o).and_return invalid_keyword_result
      fts = Zuck::TargetingSpec.new(graph, ad_account)

      fts.validate_keyword('sdjf').should == false
    end
  end

  describe "options given in spec" do
    it "accepts male as gender" do
      expect{
        Zuck::TargetingSpec.new(graph, ad_account, countries: ['US'], keywords: ['foo'], gender: 'male')
      }.to_not raise_error
    end

    it "accepts male as gender for young people" do
      expect{
        Zuck::TargetingSpec.new(graph, ad_account, countries: ['US'], keywords: ['foo'], gender: 'male', age_class: 'young')
      }.to_not raise_error
    end

    it "accepts male as gender for old people" do
      expect{
        Zuck::TargetingSpec.new(graph, ad_account, countries: ['US'], keywords: ['foo'], gender: 'male', age_class: 'old')
      }.to_not raise_error
    end

    it "accepts without gender" do
      expect{
        Zuck::TargetingSpec.new(graph, ad_account, countries: ['US'], keywords: ['foo'])
      }.to_not raise_error
    end

    it "accepts single keywrod" do
      expect{
        Zuck::TargetingSpec.new(graph, ad_account, countries: ['US'], keyword: 'foo')
      }.to_not raise_error
    end

    it "does not accept invalid genders" do
      expect{
        Zuck::TargetingSpec.new(graph, ad_account, countries: ['US'], keywords: ['foo'], gender: 'gemale')
      }.to raise_error("Gender can only be male or female")
    end

    it "does not accept targetings with neither :keywords nor :connections" do
      expect{
        ts = Zuck::TargetingSpec.new(graph, ad_account, countries: ['US'], gender: 'female')
        ts.fetch_reach
      }.to raise_error("Need to set :keywords or :connections")
    end
  end

  describe "fetching reach" do
    let(:graph){ Koala::Facebook::API.new('AAAEvJ5vzhl8BAPLr6fQgNy2wdUHDJ7ZAoX9PTZCFnebwuTBZBEqO7lNTVZA3XNsTHPTATpTmVFs6o6Jp1pZAL8ZA54BRBXWYtztVug8bm2BAZDZD') }
    let(:ad_account){ 'act_10150585630710217' }

    it "bugs out when trying to use an invalid keyword" do
      VCR.use_cassette('reach_for_invalid_keyword') do
        spec = {countries: ['us'], keywords: ['eminem', 'invalidsssssssssssssss'] }
        ts = Zuck::TargetingSpec.new(graph, ad_account, spec)
        expect{
          ts.validate_keywords
        }.to raise_error(Zuck::InvalidKeywordError, 'invalidsssssssssssssss')
      end
    end

    it "works without gender or age" do
      VCR.use_cassette('reach_for_valid_keywords') do
        spec = {countries: ['us'], keywords: ['eminem', 'sting'] }
        ts = Zuck::TargetingSpec.new(graph, ad_account, spec)
        reach = ts.fetch_reach
        reach[:users].should == 16830580
      end
    end

    it "works with gender and age" do
      VCR.use_cassette('reach_for_valid_keywords_male_young') do
        spec = {countries: ['us'], keywords: ['sting'], gender: :female, age_class: :young }
        ts = Zuck::TargetingSpec.new(graph, ad_account, spec)
        reach = ts.fetch_reach
        reach[:users].should == 39400
      end
    end

  end

  describe "Batch processing" do
    let(:graph){ Koala::Facebook::API.new('AAAEvJ5vzhl8BAPLr6fQgNy2wdUHDJ7ZAoX9PTZCFnebwuTBZBEqO7lNTVZA3XNsTHPTATpTmVFs6o6Jp1pZAL8ZA54BRBXWYtztVug8bm2BAZDZD') }
    let(:ad_account){ 'act_10150585630710217' }

    it "doesn't split up small bunches" do
      requests = [{some: :thing}] * 50
      graph.should_receive(:batch).once.and_return([])
      Zuck::TargetingSpec.batch_reaches(graph, ad_account, requests)
    end

    it "splits up into 50 request bunches" do
      requests = [{some: :thing}] * 51
      graph.should_receive(:batch).twice.and_return([])
      Zuck::TargetingSpec.batch_reaches(graph, ad_account, requests)
    end
  end
end
