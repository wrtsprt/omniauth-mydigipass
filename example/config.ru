require 'bundler/setup'
require 'sinatra'
require 'omniauth'
require 'omniauth-mydigipass'
require 'mydigipass'

# Replace these with your own credentials.
CLIENT_ID = 'YOUR-CLIENT-ID-HERE'
CLIENT_SECRET = 'YOUR-CLIENT-SECRET-HERE'

OMNIAUTH_CLIENT_OPTIONS = OmniAuth::Strategies::Mydigipass.default_client_urls
CONNECT_API_OPTIONS = { :client_id => CLIENT_ID, :client_secret => CLIENT_SECRET }

class App < Sinatra::Base
  get '/' do
    @auth = session['auth']
    if @auth.nil?
      redirect '/signin'
    else
      @users = Mydigipass::ConnectApi.new(CONNECT_API_OPTIONS).all_connected
      erb :index
    end
  end

  get '/signin' do
    @state = session['omniauth.state'] = SecureRandom.hex(24)
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
    Mydigipass::ConnectApi.new(CONNECT_API_OPTIONS).connected(params[:uuid])
    redirect '/'
  end

  get '/disconnect/:uuid' do
    Mydigipass::ConnectApi.new(CONNECT_API_OPTIONS).disconnected(params[:uuid])
    redirect '/'
  end
end

use Rack::Session::Cookie, secret: 'verysecret'
use OmniAuth::Builder do
  provider :mydigipass, CLIENT_ID, CLIENT_SECRET, :client_options => OMNIAUTH_CLIENT_OPTIONS
end

run App.new