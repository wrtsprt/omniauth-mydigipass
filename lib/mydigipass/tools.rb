module Mydigipass
  module Tools
    def self.extract_base_uri_from_options(options = { })
      if options.has_key? :base_uri
        options[:base_uri]
      else
        'https://www.mydigipass.com'
      end
    end
  end
end