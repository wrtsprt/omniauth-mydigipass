require 'bundler/setup'
require 'httparty'
require 'sinatra'
require 'omniauth'
require 'omniauth-mydigipass'

# Replace these with your own credentials.
CLIENT_ID = 'bvgr7d0nv9f1u19fj0zi581po'
CLIENT_SECRET = 'a78euy8niv5othfpjyj5kvbke'
CLIENT_OPTIONS = OmniAuth::Strategies::Mydigipass.default_client_urls(:sandbox => true)


class MdpConnectionApi
  include HTTParty
  base_uri CLIENT_OPTIONS[:site]

  def initialize(username = CLIENT_ID, password = CLIENT_SECRET)
    @auth = { :username => username, :password => password }
  end

  def all_connected
    response = self.class.get('/api/uuids/connected', { :basic_auth => @auth })
    response["uuids"] || [ ]
  end

  def connected(uuid)
    self.class.post('/api/uuids/connected', { :body => { :uuids => [ uuid ] }, :basic_auth => @auth })
  end

  def disconnected(uuid)
    self.class.post('/api/uuids/disconnected', { :body => { :uuids => [ uuid ] }, :basic_auth => @auth })
  end
end


class App < Sinatra::Base
  get '/' do
    @auth = session['auth']
    if @auth.nil?
      redirect '/signin'
    else
      @users = MdpConnectionApi.new.all_connected
      erb :index
    end
  end

  get '/signin' do
    erb :signin
  end

  get '/signout' do
    session['auth'] = nil
    redirect '/signin'
  end

  get '/auth/:name/callback' do
    session['auth'] = request.env['omniauth.auth']
    redirect '/'
  end

  get '/auth/failure' do
    session['auth'] = nil
    @request = request
    erb :failure
  end

  get '/connect/:uuid' do
    MdpConnectionApi.new.connected(params[:uuid])
    redirect '/'
  end

  get '/disconnect/:uuid' do
    MdpConnectionApi.new.disconnected(params[:uuid])
    redirect '/'
  end
end

use Rack::Session::Cookie
use OmniAuth::Builder do
  provider :mydigipass, CLIENT_ID, CLIENT_SECRET, :client_options => CLIENT_OPTIONS
end

run App.new