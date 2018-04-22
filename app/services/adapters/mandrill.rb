module Adapters
  class Mandrill

    BASE_URL = 'https://mandrillapp.com/api/1.0/'

    attr_accessor :to, :from_email, :from_name, :subject, :text,
                  :response, :id, :error


    # Creates a new instance and sets values formatted to work
    # with Mandrill's API
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
      @to = [{
        email: args['to'],
        name: args['to_name'],
        type: 'to'
      }]

      @from_email = args['from']
      @from_name  = args['from_name']
      @subject    = args['subject']
      @text       = args['body']
    end

    # Makes a call to the Mandrill API to send an email. It parses the
    # JSON response and sets it to @response and returns that value.
    # Failed requests to the Mandrill API return a single hash, while
    # successful requests return an array, but this method will take the
    # first value of the array.
    #
    # ==== Examples
    #
    #   # For the Adapters::Mandrill instance, @adapter
    #   @adapter.deliver
    #   # Executes a POST request to the Mandrill API /messages/send.json
    #   # passing in the appropriate data as json.
    #   # Returns a hash with keys "_id", "status", "email", and
    #   # "reject_reason".
    def deliver
      response =  Curl.post(BASE_URL + 'messages/send.json', email_json)
      response = JSON.parse(response.body)
      @response = response.is_a?(Array) ? response.first : response
    end


    # Return true if the email was added to Mandrill's queue and
    # false if it was not
    def sent?
      id.present? && error.blank?
    end

    # Set and return the id from Mandrills response
    def id
      @id ||= @response['_id']
    end

    # Set and return the error message from Mandrills response
    def error
      @error ||= @response['reject_reason']
    end

    private

    # Formats the JSON that is passed to the Mendrill API
    # It includes the API key, and a message hash containing
    # data about the email
    def email_json
      {
        key: ENV['MANDRILL_API_KEY'],
        message: {
          to: @to,
          from_email: @from_email,
          from_name: @from_name,
          subject: @subject,
          text: @text
        }
      }.to_json
    end

  end
end

