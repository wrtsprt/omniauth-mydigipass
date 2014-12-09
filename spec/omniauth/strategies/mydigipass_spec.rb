require 'spec_helper'
require 'omniauth-mydigipass'

describe OmniAuth::Strategies::Mydigipass do
  subject do
    OmniAuth::Strategies::Mydigipass.new('abc', 'def', @options || {})
  end

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  it_should_behave_like 'an oauth2 strategy'

  describe '#client' do
    it 'should have the correct mydigipass.com site' do
      subject.client.site.should == 'https://www.mydigipass.com'
    end

    it 'should have the correct authorization url' do
      subject.client.options[:authorize_url].should == 'https://www.mydigipass.com/oauth/authenticate'
    end

    it 'should have the correct token url' do
      subject.client.options[:token_url].should == 'https://www.mydigipass.com/oauth/token'
    end
  end

  describe '#callback_path' do
    it 'should have the correct callback path' do
      subject.callback_path.should eq('/auth/mydigipass/callback')
    end
  end
end