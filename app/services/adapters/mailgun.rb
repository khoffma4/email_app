module Adapters
  class Mailgun

    BASE_URL = 'https://api:' + ENV['MAILGUN_API_KEY'] + '@api.mailgun.net/v3/' + ENV['MAILGUN_DOMAIN'] + '/'

    attr_accessor :to, :from, :subject, :text, :response

    def initialize(args)
      @to      = "#{args['to_name']} <#{args['to']}>"
      @from    = "#{args['from_name']} <#{args['from']}>"
      @subject = args['subject']
      @text    = args['body']
    end

    def deliver
      response = Curl::Easy.http_post(
        BASE_URL + 'messages',
        Curl::PostField.content('to',      @to),
        Curl::PostField.content('from',    @from),
        Curl::PostField.content('subject', @subject),
        Curl::PostField.content('text',    @text)
      )
      @response = JSON.parse(response.body)
    end

  end
end

