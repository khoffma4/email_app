class SendEmail
  include ActiveModel::Validations
  include HtmlToPlainText

  attr_accessor :to, :to_name, :from, :from_name, :subject, :body

  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  validates_presence_of :to_name, :from_name, :subject, :body
  validates :to, presence: true, format: { with: EMAIL_REGEX }
  validates :from, presence: true, format: { with: EMAIL_REGEX }

  # Creates a new instance and sets arguments hash values to
  # instance variables
  #
  # ==== Attributes
  #
  # * +args+ - A hash or ActionController::Parameters instance
  #            containing the keys :to, :to_name, :from,
  #            :from_name, :subject, and :body
  #
  # ==== Examples
  #
  #  SendEmail.new(
  #    'to'        => "fake@example.com",
  #    'to_name'   => "Mr. Fake",
  #    'from'      => "noreply@mybrightwheel.com",
  #    'from_name' => "Brightwheel",
  #    'subject'   => "A Message from Brightwheel",
  #    'body'      => "<h1>Your Bill</h1><p>$10</p>"
  #  )
  #
  def initialize(args={})
    args = args.stringify_keys
    @to        = args['to']
    @to_name   = args['to_name']
    @from      = args['from']
    @from_name = args['from_name']
    @subject   = args['subject']
    @body      = convert_to_text(args['body'])
  end

  # Delivers the email using the email adapter and
  # returns true if the object is valid. If the
  # object is not valid, it does not deliver the email
  # and returns false.
  #
  # ==== Examples
  #
  #  @send_email.deliver => true
  #
  def deliver
    if valid?
      email_client.deliver
      true
    else
      false
    end
  end

  # Overrides the JSON method to include some values
  # from the email_client
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

  # Initializes a new instance of the EMAIL_ADAPTER
  # class if one has not already been initialized,
  # passing in values for :to, :to_name, :from,
  # :from_name, :subject, and :body.
  def email_client
    @email_client ||= EMAIL_ADAPTER.new(
      to:        @to,
      to_name:   @to_name,
      from:      @from,
      from_name: @from_name,
      subject:   @subject,
      body:      @body
    )
  end

end
