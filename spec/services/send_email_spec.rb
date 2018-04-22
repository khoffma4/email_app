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

  describe '.deliver' do
    it "sends the email" do
      email = SendEmail.new(valid_input)
      client = email.send(:email_client)
      expect(client).to receive(:deliver)
      email.deliver
    end
  end

end
