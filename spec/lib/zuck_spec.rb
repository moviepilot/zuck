require 'spec_helper'

describe Zuck::FbObject do

  before(:all) {
    puts "Koala version: #{Koala.config.api_version}"
    Zuck.graph = Koala::Facebook::API.new(test_access_token)
  }


  let(:graph)   { Zuck.graph                                                  }
  let(:account_id) { "act_367106653" }
  let(:account) { Zuck::AdAccount.new(graph,  {id: account_id})  }

  describe "talking to facebook" do
    act_campaign = nil
    campaign = nil
    creative = nil
    group = nil
    set = nil

    context "creating" do

      it "an ad campaign via an existing ad account" do
        VCR.use_cassette('create_ad_campaign') do
          o = {
              daily_budget: 1000,
              name: "bloody campaign (via account)"
          }
          explain_error {
            act_campaign = account.create_ad_campaign(o)
            act_campaign.name.should == "bloody campaign (via account)"
          }
        end
      end


      it "an ad campaign" do
        VCR.use_cassette('create_ad_campaign') do
          o = {
              objective: 'NONE',
              name: "bloody campaign",
              campaign_group_status: 'PAUSED'
          }
          explain_error {
            campaign = Zuck::AdCampaign.create(graph, o, account)
            campaign.name.should == "bloody campaign"
          }
        end
      end

      it "an ad set" do
        VCR.use_cassette('create_ad_set') do
          o = {
              bid_type: 'CPC',
              bid_info: "{'CLICKS': 1}",
              name: 'bloody ad set',
              campaign_status: 'PAUSED',
              daily_budget: 100,
              targeting: "{'geo_locations':{'countries':['US','GB']}}",
              campaign_group_id: campaign.id
          }
          explain_error {
            set = Zuck::AdSet.create(graph, o, account)
            set.name.should == 'bloody ad set'
          }
        end
      end

      it "a creative by uploading an image" do
        VCR.use_cassette('create a creative') do
          o =  {
              title: 'bloody title',
              body: 'bloody body',
              object_url: 'http://moviepilot.com/',
              image_url: 'http://images-cdn.moviepilot.com/image/upload/c_fill,h_246,w_470/v1427727623/moviepilot.jpg'
          }
          explain_error {
            creative = Zuck::AdCreative.create(graph, o, account)
            creative.id.should_not == nil
          }
        end
      end


      it "an ad group via an existing ad campaign" do
        VCR.use_cassette('create_ad_group') do
          o = {
              name: "Rap like me",
              # targeting: '{"geo_locations": {"countries":["US"]}}',
              objective: 'WEBSITE_CLICKS',
              creative: '{"creative_id": '+creative.id+'}'
          }
          explain_error {
            group = set.create_ad_group(o)
            group.name.should == "Rap like me"
            group['bid_type'].should == 'CPC'
          }
        end
      end
    end

    context "reading" do

      it "a list of ad accounts" do
        VCR.use_cassette('list_of_ad_accounts') do
          Zuck::AdAccount.all.should have_at_least(1).items
        end
      end

      it "a list of ad campaigns" do
        VCR.use_cassette('list_of_ad_campaigns') do
          account.ad_campaigns.should have_at_least(2).items
        end
      end

      it "a list of ad groups" do
        VCR.use_cassette('list_of_ad_groups') do
          campaign.ad_groups.should have_at_least(1).item
        end
      end

      it "list of ad creatives" do
        VCR.use_cassette('list_of_ad_creatives') do
          group.ad_creatives.should have(1).items
        end
      end

      it "list of all ad creatives of an account" do
        g = graph
        Zuck::AdAccount.should_receive(:all).and_return([account])
        VCR.use_cassette('list_of_all_ad_creatives_of_account') do
          Zuck::AdCreative.all(g).should have_at_least(1).items
        end
      end

      context "an id directly" do

        it "campaign with the correct type" do
          VCR.use_cassette('a_single_campaign') do
            c = Zuck::AdCampaign.find(campaign.id, graph)
            c.buying_type.should == "AUCTION"
          end
        end

        it "account with the correct type" do
          VCR.use_cassette('a_single_account') do
            c = Zuck::AdAccount.find(account_id, graph)
            c.account_id.should == account_id[4..-1]
            c.account_status.should == 1
          end
        end

        it "when expecting an ad group but the id belongs to a campaign" do
          VCR.use_cassette('a_single_group') do
            expect{
              Zuck::AdGroup.find(campaign.id, graph)
            }.to raise_error(Koala::Facebook::ClientError)
          end
        end

        it "and saving it" do
          VCR.use_cassette('find_a_single_group_and_update_it') do
            explain_error {
              found_group = Zuck::AdGroup.find(group.id, graph)
              found_group.name = "My old name"
              found_group.save
              found_group.name.should == "My old name"
              found_group.name = "My new name"
              found_group.save
              found_group.name.should == "My new name"
              found_group.reload
              found_group.name.should == "My new name"
            }
          end
        end

      end
    end

    context "deleting" do
      it "an ad group" do
        VCR.use_cassette('delete_ad_group') do
          group.destroy.should be_true
        end
      end

      it "an ad set" do
        VCR.use_cassette('delete_ad_set') do
          set.destroy.should be_true
        end
      end

      it "a creative" do
        VCR.use_cassette('delete_creative') do
          creative.destroy.should be_true
        end
      end

      it "a campaign" do
        VCR.use_cassette('delete_campaign') do
          campaign.destroy.should be_true
          act_campaign.destroy.should be_true
        end
      end
    end
  end
end
