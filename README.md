# OmniAuth Mydigipass

This is an OmniAuth strategy for authenticating with MYDIGIPASS.COM.

If you want to integrate your website with MYDIGIPASS.COM, you will need to
sign up on [developer.mydigipass.com](http://developer.mydigipass.com) and
create an application. Checkout our [Getting Started Guide](https://developer.mydigipass.com/getting_started)
for step by step instructions of setting up your application. You will get a `client_id` and `client_secret`
you need to fill in here.

It is recommended to use the OAuth `state` parameter to prevent CSRF
attacks. Omniauth actually enables this behaviour by default. Usage of the
state parameter is illustrated in the example app.


## Basic Usage

Initialize the strategy as follows:

```ruby
use OmniAuth::Builder do
  provider :mydigipass, ENV['MYDIGIPASS_CLIENT_ID'], ENV['MYDIGIPASS_CLIENT_SECRET']
end
```


## Example Integrating with Rails

Add an initializer `mydigipass.rb` containing your application specific configuration. Testing on your local
machine is possible using a localhost redirect URI.

```ruby
# MYDIGIPASS.COM OAuth configuration

MDP_JS_SRC="https://static.mydigipass.com/en/dp_connect.js"

MDP_CLIENT_ID="<your-production-client-id>"
MDP_CLIENT_SECRET="<your-production-client-secret>"

if Rails.env.production?
  MDP_CALLBACK_URL="<your-production-base-url>/auth/mydigipass/callback"
else
  MDP_CALLBACK_URL="http://localhost:3000/auth/mydigipass/callback"
end
```

Inside your `config/application.rb` add the following (e.g. at the bottom, inside the configuration block) :

```ruby
# enable omniauth strategies
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :mydigipass, MDP_CLIENT_ID, MDP_CLIENT_SECRET
end
```

And then you just have to make sure you have something listening at `/auth/:provider/callback`.
Suppose you add the following routes:

```ruby
match '/auth/:provider/callback', :to => 'home#auth_create'
match '/auth/failure', :to => 'home#auth_failure'
```


### Rendering the Secure Login button

On the login page and/or signup page, you can show the MYDIGIPASS.COM button
as follows:

```ruby
= link_to("connect with mydigipass.com", "#", :class => "dpplus-connect",
                                              :"data-is-sandbox" => true,
                                              :"data-client-id" => MDP_CLIENT_ID,
                                              :"data-redirect-uri" => MDP_CALLBACK_URL,
                                              :"data-state" => @state)
```

and also include the `dp_connect.js` Javascript file:

```ruby
%script{:type => 'text/javascript', :src => MDP_JS_SRC}
```

Since you can potentially link a MYDIGIPASS.COM account to an
existing account on your site, you have to protect against CSRF attacks.
For this reason, every time you render a view with the above link,
you have to generate a new random CSRF-protection `state` token.
This token must be stored in two places:

1. in the `data-state` attribute of the link itself (see above code),
2. in the `omniauth.state` session variable.

To generate a suitable token, you can put the following code in the
controller action or even in the view itself:

```ruby
@state = session['omniauth.state'] = SecureRandom.hex(24)
```

When Omniauth is processing the OAuth call, it will compare the
`state` parameter passed back in by MIDIGPASS.COM to the `omniauth.state`
parameter stored in the user's session. If the tokens do not match, Omniauth
will conclude that the authentication was originally initiated in another
browser session and abort the remainder of the flow.

> Note: If you use the `state` parameter for CSRF protection, you must
> register a separate autoconnect URL (which is usually the URL of the
> login page of your application) with MYDIGIPASS.COM to enable users to
> sign in from our launchpad.


### Handling the callback

To handle the actual callback, you can use something like the following
`auth_create` implementation inside your `HomeController`:

```ruby
def auth_failure
  set_flash_message(:notice, "OAuth error: #{params[:message]}")
  redirect_to root_path
end

def auth_create
  user = User.find_or_create_from_auth_hash(request.env['omniauth.auth'].with_indifferent_access)
  logger.debug "Found or created user: #{user.email} [#{user.id}]"
  if user.sign_in_count == 0
    set_flash_message(:notice, "Welcome #{user.email}, thank you for signing up using your dP+ account!")
  else
    set_flash_message(:notice, "Succesfully logged in!")
  end
  sign_in(:user, user, :bypass => true)
  redirect_to dashboard_path
end
```

When a user signs in through MYDIGIPASS.COM, it could be a new user
(signing up), or an existing user. The function `find_or_create_from_auth_hash`
handles that for me:

```ruby
def self.find_or_create_from_auth_hash(auth_hash)
  logger.debug "User.find_or_create_from_auth_hash: auth_hash = #{auth_hash.inspect} "
  received_uuid = auth_hash[:extra][:raw_info][:uuid]
  received_email = auth_hash[:extra][:raw_info][:email]

  user = User.find_by_uuid(received_uuid) || User.find_by_email(received_email)
  user = user.nil? ? create_from_auth_hash(received_uuid, received_email) : prevent_login_with_normal_password(user, received_uuid)
end
```

Find the user, by `uuid` or `email`. If user is found by `uuid`,
she has logged on before with MYDIGIPASS.COM.  If a matching mail is found,
link the uuid to that user. If user isn't found, create one with the
given `email` and `uuid`.

Should users only be allowed to to login via MYDIGIPASS.COM, the other sign in method has to be disabled.
This step is optional.


## Example Application

There is a small, fully working Sinatra based example application in the `example` folder.
To make it work just type `rackup` in the folder.

Aside from signing in with MYDIGIPASS.COM, the example application also
shows how to use the Connect API through a simple HTTParty wrapper that can
be found in `lib/mydigipass/connect_api.rb`.

The Connect API and its purpose is described in more detail in the
[MDP Developer documentation](https://developer.mydigipass.com/).


## License

Copyright (c) 2012 Nathan Van der Auwera

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.