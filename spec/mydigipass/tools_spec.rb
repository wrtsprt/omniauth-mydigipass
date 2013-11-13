require 'spec_helper'
require 'mydigipass/tools'

describe Mydigipass::Tools do
  describe '.extract_base_uri_from_options' do
    context 'with no options parameter' do
      Mydigipass::Tools.extract_base_uri_from_options().should == 'https://www.mydigipass.com'
    end

    context 'with empty hash' do
      Mydigipass::Tools.extract_base_uri_from_options({}).should == 'https://www.mydigipass.com'
    end

    context 'with explicit base_uri' do
      Mydigipass::Tools.extract_base_uri_from_options({ :base_uri => 'https://www.foo.com', :sandbox => true }).should == 'https://www.foo.com'
    end

    context 'with sandbox option' do
      Mydigipass::Tools.extract_base_uri_from_options({ :sandbox => true }).should == 'https://sandbox.mydigipass.com'
    end
  end
end