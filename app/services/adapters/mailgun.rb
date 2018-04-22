module Adapters
  class Mailgun

    BASE_URL = 'https://api:' + ENV['MAILGUN_API_KEY'] + '@api.mailgun.net/v3/' + ENV['MAILGUN_DOMAIN'] + '/'

    attr_accessor :to, :from, :subject, :text, :response, :id, :error

    # Creates a new instance and sets values formatted to work
    # with Mailgun's API
    #
    # ==== Attributes
    #
    # * +args+ - A hash containing the keys 'to', 'to_name',
    #            'from', 'from_name', 'subject', and 'body'
    #
    # ==== Examples
    #  Adapter::Mailgun.new(
    #    'to'        => "fake@example.com",
    #    'to_name'   => "Mr. Fake",
    #    'from'      => "noreply@mybrightwheel.com",
    #    'from_name' => "Brightwheel",
    #    'subject'   => "A Message from Brightwheel",
    #    'body'      => "<h1>Your Bill</h1><p>$10</p>"
    #  )
    #
    def initialize(args)
      @to      = "#{args['to_name']} <#{args['to']}>"
      @from    = "#{args['from_name']} <#{args['from']}>"
      @subject = args['subject']
      @text    = args['body']
    end


    # Makes a call to the Mailgun API to send an email. It parses the
    # JSON response and sets it to @response and returns that value.
    #
    # ==== Examples
    #
    #   # For the Adapters::Mailgun instance, @adapter
    #   @adapter.deliver
    #   # Executes a POST request to the Mailgun API /messages
    #   # passing in to, from, subject, and text as form parameters
    #   # Returns a has with keys "id" and "message" for successful
    #   # requests and only "message" for failed requests.
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


    # Return true if the email was added to Mailgun's queue and
    # false if it was not
    def sent?
      id.present?
    end

    # Return true if the email was added to Mailgun's queue and
    # false if it was not
    def id
      @id ||= @response['id']
    end

    # Set and return the error message from Mandrills response
    # If there is an id in Mandrill's response, then the message
    # key does not hold an error message
    def error
      return unless id.nil?
      @error ||= @response['message']
    end

  end
end

