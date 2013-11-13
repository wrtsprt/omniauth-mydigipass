require 'httparty'
require 'mydigipass/tools'

module Mydigipass
  class ConnectApi
    def initialize(options)
      @base_uri = Mydigipass::Tools.extract_base_uri_from_options(options)
      @auth = { :username => options[:client_id], :password => options[:client_secret] }
    end

    def all_connected
      response = HTTParty.get("#{@base_uri}/api/uuids/connected", { :basic_auth => @auth })
      response['uuids'] || [ ]
    end

    def connected(uuid)
      HTTParty.post("#{@base_uri}/api/uuids/connected", { :body => { :uuids => [ uuid ] }, :basic_auth => @auth })
    end

    def disconnected(uuid)
      HTTParty.post("#{@base_uri}/api/uuids/disconnected", { :body => { :uuids => [ uuid ] }, :basic_auth => @auth })
    end
  end
end