require 'spec_helper'

describe Zuck::AdAccount do

  let(:graph){ Koala::Facebook::API.new(:token) }
  let(:acc){ Zuck::AdAccount.new(graph, lets: :dance_in_style) }

  it "initializes graph correctly" do
    acc.graph.should == graph
  end

  it "initializes data correctly" do
    acc[:lets].should == :dance_in_style
  end

  describe "talking to facebook" do

    before(:all) do
      Zuck.graph = Koala::Facebook::API.new('AAAEvJ5vzhl8BAG3qjJXGVUVKTzjMLrirxcVxllKJdthkQrEstIgXzMYZAAzg0ETsCGMGmX9UvUh4ZCGvATX9ZCnjNee18OTtQ9ZAarrDBQZDZD')
    end

    it "fetches a list of ad accounts" do
      VCR.use_cassette('list_of_ad_accounts') do
        Zuck::AdAccount.all.should have(1).item
      end
    end

    it "fetches a list of ad campaigns" do
      account = Zuck::AdAccount.new(Zuck.graph, id: "act_10150585630710217")
      VCR.use_cassette('list_of_ad_campaigns') do
        account.ad_campaigns.should have(1).item
      end
    end

    it "fetches a list of ad groups" do
      campaign = Zuck::AdCampaign.new(Zuck.graph, id: "6004497037951")
      VCR.use_cassette('list_of_ad_groups') do
        campaign.ad_groups.should have(3).items
      end
    end

    it "fetches a list of ad creatives" do
      group = Zuck::AdGroup.new(Zuck.graph, id: "6004497038951")
      VCR.use_cassette('list_of_ad_creatives') do
        group.ad_creatives.should have(1).items
      end
    end
  end

end
