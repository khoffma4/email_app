class SendEmail
  include ActiveModel::Model

  attr_accessor :to, :to_name, :from, :from_name, :subject, :body

  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  validates_presence_of :to_name, :from_name, :subject, :body
  validates :to, presence: true, format: { with: EMAIL_REGEX }
  validates :from, presence: true, format: { with: EMAIL_REGEX }

  def initialize(params={})
    params = params.stringify_keys
    @to        = params['to']
    @to_name   = params['to_name']
    @from      = params['from']
    @from_name = params['from_name']
    @subject   = params['subject']
    @body      = params['body']
  end

  def deliver
    email_client.deliver(
      to:        @to,
      to_name:   @to_name,
      from:      @from,
      from_name: @from_name,
      subject:   @subject,
      body:      @body
    )
  end

  private

  def email_client
    @email_client ||= OpenStruct.new(deliver: true)
  end

end
