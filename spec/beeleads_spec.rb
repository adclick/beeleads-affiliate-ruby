require 'spec_helper'
require 'beeleads'

describe Beeleads::Client do
  describe 'api_url' do
    it 'has a default value' do
      client = Beeleads::Client.new()
      client.instance_variable_get(:@api_url).should eq('https://hive.bldtools.com/api.php/v1/lead/')
    end
  end

  describe '.new' do
    %w(api_url api_affiliate_id api_secret api_offer_id).each do |k|
      it 'should set the #{k} option' do
        client = Beeleads::Client.new({k.to_sym => k})
        client.instance_variable_get(:"@#{k}").should eq(k)
      end
    end

    it 'should not set the any_other option' do
      client = Beeleads::Client.new({:any_other => 'something'})
      client.instance_variable_get(:@any_other).should be_nil
    end
  end

  describe '#lead' do
    subject { Beeleads::Client.new({:api_affiliate_id => 123, :api_secret => 'secret', :api_offer_id => 7}) }
    let(:lead) { { :email => 'sample@example.net', :firstname => 'Tiago' } }

    before :each do
      Beeleads::Client.stub(:token).with(lead) { 'token' }
      stub_request(:get, 'https://hive.bldtools.com/api.php/v1/lead/').with(:query => {'token' => 'token', 'affiliate_id' => 123, 'offer_id' => 7, :field => lead})
      subject.lead(lead)
    end

    it 'should make a get request' do
      a_request(:get, 'https://hive.bldtools.com/api.php/v1/lead/').with(:query => {'token' => 'token', 'affiliate_id' => 123, 'offer_id' => 7, 'field' => lead}).should have_been_made.once
    end
  end

  describe '.token' do
    it 'should return the correct token' do
      Beeleads::Client.class_eval { token('yoursecret', { :email => 'sample@example.net', :firstname => 'Tiago' }) }.should eq('c474a686e1e404936c8662cb1aa68d45e86995c0')
    end
  end

  describe '.token_query' do
    it 'should return the correct encoded form data' do
      Beeleads::Client.class_eval { token_query({ :email => 'sample@example.net', :firstname => 'Tiago' }) }.should eq('email=sample%2540example.net&firstname=Tiago')
    end
  end
end
