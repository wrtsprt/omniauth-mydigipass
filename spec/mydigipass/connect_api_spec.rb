require 'spec_helper'
require 'mydigipass/connect_api'

describe Mydigipass::ConnectApi do
  let(:client_id) { 'abc' }
  let(:client_secret) { 'def' }
  let(:uuid) { 'ghi' }

  let(:basic_auth) { { :username => client_id, :password => client_secret } }

  before :each do
    @api = Mydigipass::ConnectApi.new(:client_id => client_id, :client_secret => client_secret, :base_uri => 'https://www.foo.com')
    HTTParty.stub(:get)
    HTTParty.stub(:post)
  end

  describe '#all_connected' do
    it 'performs GET and returns array' do
      params = { :basic_auth => basic_auth }
      HTTParty.should_receive(:get).with('https://www.foo.com/api/uuids/connected', params).and_return({ 'uuids' => [ '123', '456' ] })
      @api.all_connected.should == [ '123', '456' ]
    end
  end

  describe '#connected' do
    it 'performs POST' do
      params = { :body => { :uuids => [ uuid ] }, :basic_auth => basic_auth }
      HTTParty.should_receive(:post).with('https://www.foo.com/api/uuids/connected', params)
      @api.connected(uuid)
    end
  end

  describe '#disconnected' do
    it 'performs POST' do
      params = { :body => { :uuids => [ uuid ] }, :basic_auth => basic_auth }
      HTTParty.should_receive(:post).with('https://www.foo.com/api/uuids/disconnected', params)
      @api.disconnected(uuid)
    end
  end
end