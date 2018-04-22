require 'rails_helper'

describe SendEmail do

  let(:valid_input) {
    { 'to'        => "fake@example.com",
      'to_name'   => "Mr. Fake",
      'from'      => "noreply@mybrightwheel.com",
      'from_name' => "Brightwheel",
      'subject'   => "A Message from Brightwheel",
      'body'      => "<h1>Your Bill</h1><p>$10</p>" }
  }

  describe '#new' do
    it 'sets fields when initialized' do
      email = SendEmail.new(valid_input)
      expect(email.to).to eql 'fake@example.com'
      expect(email.from).to eql 'noreply@mybrightwheel.com'
    end
  end

  describe "validations" do
    it "returns true when all fields are valid" do
      expect(SendEmail.new(valid_input).valid?).to eql true
    end

    it 'requires a proper email address format for "to"' do
      invalid_input = valid_input.merge('to' => "not_an_email")
      expect(SendEmail.new(invalid_input).valid?).to eql false
    end

    it 'requires a proper email address format for "from"' do
      invalid_input = valid_input.merge('from' => "not_an_email")
      expect(SendEmail.new(invalid_input).valid?).to eql false
    end

    it 'requires a value for "to"' do
      email = SendEmail.new(valid_input.except('to'))
      expect(email.valid?).to eql false
    end

    it 'requires a value for "to_name"' do
      email = SendEmail.new(valid_input.except('to_name'))
      expect(email.valid?).to eql false
    end

    it 'requires a value for "from"' do
      email = SendEmail.new(valid_input.except('from'))
      expect(email.valid?).to eql false
    end

    it 'requires a value for "from_name"' do
      email = SendEmail.new(valid_input.except('from_name'))
      expect(email.valid?).to eql false
    end

    it 'requires a value for "subject"' do
      email = SendEmail.new(valid_input.except('subject'))
      expect(email.valid?).to eql false
    end

    it 'requires a value for "body"' do
      email = SendEmail.new(valid_input.except('body'))
      expect(email.valid?).to eql false
    end
  end

  describe '#adapter' do
    before(:each) { @client = ENV['EMAIL_CLIENT'] }
    after(:each) { ENV['EMAIL_CLIENT'] = @client }

    it "uses Mandrill if the ENV is not sent" do
      ENV['EMAIL_CLIENT'] = nil
      expect(SendEmail.adapter).to eql Adapters::Mandrill
    end

    it "is a Adapters::Mandrill object" do
      ENV['EMAIL_CLIENT'] = 'Mandrill'
      expect(SendEmail.adapter).to eql Adapters::Mandrill
    end

    it "is a Adapters::Mailgun object" do
      ENV['EMAIL_CLIENT'] = 'Mailgun'
      expect(SendEmail.adapter).to eql Adapters::Mailgun
    end
  end

  describe '.deliver' do
    it "sends the email" do
      adapter = SendEmail.adapter
      expect_any_instance_of(adapter).to receive(:deliver).and_return(true)
      email = SendEmail.new(valid_input)
      email.deliver
    end
  end

  describe '.email_client' do
    it 'is an instance of the adapter' do
      adapter = SendEmail.adapter
      email = SendEmail.new(valid_input)
      expect(email.send(:email_client)).to be_a adapter
    end
  end

  describe '.to_json' do
    before(:each) do
      allow_any_instance_of(SendEmail.adapter).to receive(:id).and_return('email_id')
      allow_any_instance_of(SendEmail.adapter).to receive(:sent?).and_return(true)
      @send_email = SendEmail.new(valid_input)
    end

    it "has the email id" do
      expect(JSON.parse(@send_email.to_json)['id']).to eql 'email_id'
    end

    it "includes if the email was sent" do
      expect(JSON.parse(@send_email.to_json)['sent']).to eql true
    end

    it "has the email service provider" do
      expect(
        JSON.parse(@send_email.to_json)['email_client']
      ).to eql ENV['EMAIL_CLIENT']
    end
  end

end
