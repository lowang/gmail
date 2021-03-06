require 'gmail_xoauth'
require 'ostruct'

module Gmail
  module Client
    class XOAuth2 < Base
      attr_reader :oauth2_token

      def initialize(username, options={})
        @oauth2_token           = options.delete(:oauth2_token)

        super(username, options)
      end

      def login(raise_errors=false)
        @imap and @logged_in = (login = @imap.authenticate('XOAUTH2', username,
          oauth2_token)) && login.name == 'OK'
      rescue StandardError => e
        raise_errors and raise AuthorizationError, OpenStruct.new(data: OpenStruct.new(text: "Couldn't login to given GMail account: #{username} [#{e.message}]"))
      end

     def smtp_settings
        [:smtp, {
           :address => GMAIL_SMTP_HOST,
           :port => GMAIL_SMTP_PORT,
           :domain => mail_domain,
           :user_name => username,
           :password => oauth2_token,
           :authentication => :xoauth2,
           :enable_starttls_auto => true
       }]
      end
    end # XOAuth2

    register :xoauth2, XOAuth2
  end # Client
end # Gmail
