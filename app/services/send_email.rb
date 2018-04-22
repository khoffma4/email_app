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
    if valid?
      email_client.deliver
      true
    else
      false
    end
  end

  def self.adapter
    adapter = ENV['EMAIL_CLIENT'] || 'Mandrill'

    { 'Mandrill' => Adapters::Mandrill,
      'Mailgun'  => Adapters::Mailgun }[adapter]
  end

  def to_json
    {
      email_client: ENV['EMAIL_CLIENT'],
      id: email_client.id,
      sent: email_client.sent?,
      to: @to,
      to_name: @to_name,
      from: @from,
      from_name: @from_name,
      subject: @subject,
      body: @body
    }.to_json
  end


  private

  def email_client
    @email_client ||= SendEmail.adapter.new(
      to:        @to,
      to_name:   @to_name,
      from:      @from,
      from_name: @from_name,
      subject:   @subject,
      body:      @body
    )
  end

end
