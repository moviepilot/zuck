require 'spec_helper'

describe Zuck do
  describe "assigning a graph instance" do

    it "raises when not a Koala instance" do
      expect{
        Zuck.graph = :something_else
      }.to raise_error "Symbol is not a Koala::Facebook::API"
      Zuck.graph.should be_nil
    end

    it "raises when not a Koala instance" do
      expect{
        Zuck.graph = Koala::Facebook::API.new()
      }.to raise_error
      Zuck.graph.should be_nil
    end

    it "that's valid" do
      Zuck.graph.should be_nil
      Zuck.graph = Koala::Facebook::API.new(:some_token)
      Zuck.graph.should_not be_nil
    end
  end
end
