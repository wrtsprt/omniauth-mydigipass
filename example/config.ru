require 'bundler/setup'
require 'sinatra'
require 'omniauth'
require 'omniauth-mydigipass'

# Replace these with your own credentials.
CLIENT_ID = 'bvgr7d0nv9f1u19fj0zi581po'
CLIENT_SECRET = 'a78euy8niv5othfpjyj5kvbke'

class App < Sinatra::Base
  get '/' do
    content_type 'text/html'
    <<-HTML
      <h1>Test OAuth2 with MYDIGIPASS.COM</h1>
      <script  type="text/javascript" src="https://static.mydigipass.com/en/dp_connect.js"></script>
      <a class="dpplus-connect" data-origin="https://sandbox.mydigipass.com" data-client-id=#{CLIENT_ID} data-redirect-uri="http://localhost:9292/auth/mydigipass/callback" href="#">connect with mydigipass.com</a>
    HTML
  end

  get '/auth/:name/callback' do
    @auth = request.env['omniauth.auth']
    erb :callback
  end

  get '/auth/failure' do
    @request = request
    erb :failure
  end
end

use Rack::Session::Cookie
use OmniAuth::Builder do
  provider :mydigipass, CLIENT_ID, CLIENT_SECRET,
           :client_options => OmniAuth::Strategies::Mydigipass.default_client_urls(:sandbox => true)
end

run App.new