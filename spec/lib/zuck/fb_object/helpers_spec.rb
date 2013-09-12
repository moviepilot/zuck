require 'spec_helper'

class HTest
  extend  Zuck::FbObject::Helpers
  include Zuck::FbObject::Helpers
  def self.known_keys; []; end
end

describe Zuck::FbObject::Helpers do

  let(:graph_mock){ mock('graph') }

  context "get" do
    it "forwards to koala" do
      graph_mock.should_receive(:get_object).with('/foo', fields: '').and_return(true)
      HTest.send(:get, graph_mock, "/foo")
    end

    it "does not swallow exceptions" do
      graph_mock.should_receive(:get_object).with('/foo', fields: '').and_raise("broken")
      expect{
        HTest.send(:get, graph_mock, "/foo")
      }.to raise_error("broken")
    end
  end

  context "create_connection" do
    it "forwards to koala" do
      graph_mock.should_receive(:put_connections).with(:parent, :connection, :args, :opts).and_return(true)
      HTest.send(:create_connection, graph_mock, :parent, :connection, :args, :opts)
    end

    it "does not swallow exceptions" do
      graph_mock.should_receive(:put_connections).with(:parent, :connection, :args, :opts).and_raise("broken")
      expect{
        HTest.send(:create_connection, graph_mock, :parent, :connection, :args, :opts)
      }.to raise_error("broken")
    end
  end

  context "post" do
    it "forwards to koala" do
      graph_mock.should_receive(:graph_call).with("path", :data, "post", :opts).and_return(true)
      HTest.send(:post, graph_mock, :path, :data, :opts)
    end

    it "does not swallow exceptions" do
      graph_mock.should_receive(:graph_call).with("path", :data, "post", :opts).and_raise("broken")
      expect{
        HTest.send(:post, graph_mock, :path, :data, :opts)
      }.to raise_error("broken")
    end
  end

  context "delete" do
    it "forwards to koala" do
      graph_mock.should_receive(:delete_object).with(:id).and_return(true)
      HTest.send(:delete, graph_mock, :id)
    end

    it "does not swallow exceptions" do
      graph_mock.should_receive(:delete_object).with(:id).and_raise("broken")
      expect{
        HTest.send(:delete, graph_mock, :id)
      }.to raise_error("broken")
    end
  end
end
