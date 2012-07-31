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

end
