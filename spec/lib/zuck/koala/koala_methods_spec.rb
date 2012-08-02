require 'spec_helper'

class KMTest
  extend Zuck::KoalaMethods
end

describe Zuck::KoalaMethods do
  describe "assigning a graph instance" do

    it "raises when not a Koala instance" do
      expect{
        KMTest.graph = :something_else
      }.to raise_error "Symbol is not a Koala::Facebook::API"
      KMTest.graph.should be_nil
    end

    it "raises when not a Koala instance" do
      expect{
        KMTest.graph = Koala::Facebook::API.new()
      }.to raise_error
      KMTest.graph.should be_nil
    end

    it "that's valid" do
      KMTest.graph.should be_nil
      KMTest.graph = Koala::Facebook::API.new(:some_token)
      KMTest.graph.should_not be_nil
    end
  end
end
