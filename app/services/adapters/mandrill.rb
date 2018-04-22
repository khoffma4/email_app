module Adapters
  class Mandrill

    BASE_URL = 'https://mandrillapp.com/api/1.0/'

    attr_accessor :to, :from_email, :from_name, :subject, :text,
                  :response, :id, :error

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

    def deliver
      response =  Curl.post(BASE_URL + 'messages/send.json', email_json)
      response = JSON.parse(response.body)
      @response = response.is_a?(Array) ? response.first : response
    end

    def sent?
      id.present? && error.blank?
    end

    def id
      @id ||= @response['_id']
    end

    def error
      @error ||= @response['reject_reason']
    end

    private

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

