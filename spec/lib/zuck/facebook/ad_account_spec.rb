require 'spec_helper'

describe Zuck::AdAccount do

  let(:graph){ Koala::Facebook::API.new(:token) }
  let(:acc){ Zuck::AdAccount.new(graph, name: :dance_in_style) }

  it "initializes graph correctly" do
    acc.graph.should == graph
  end

  it "initializes data correctly" do
    acc[:name].should == :dance_in_style
  end

  it "defines getters" do
    acc.name.should == :dance_in_style
  end

  it "defines setters" do
    acc.name = :bazinga
    acc.name.should == :bazinga
  end


end
