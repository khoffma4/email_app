require 'rails_helper'

describe Adapters::Mailgun do

  describe "#new" do
    it 'sets the "to" array' do
      mailgun = Adapters::Mailgun.new(input)
      expect(mailgun.to).to eql "Mr. Fake <" +  ENV['MAILGUN_SANDBOX_EMAIL'] + ">"
    end

    it 'sets the "text" field' do
      mailgun = Adapters::Mailgun.new(input)
      expect(mailgun.text).to eql "Your Bill is $10"
    end
  end

  describe 'deliver' do
    context 'when the email is valid' do
      before(:all) do
        mailgun = Adapters::Mailgun.new(input)
        @response = mailgun.deliver
      end

      it "gets added to a queue" do
        expect(@response['message']).to eql 'Queued. Thank you.'
      end

      it "does as a message id" do
        expect(@response['id']).to be_present
      end
    end

    context 'when the email is invalid' do
      before(:all) do
        mailgun = Adapters::Mailgun.new(input.except('from'))
        @response = mailgun.deliver
      end

      it 'does not get queued' do
        expect(@response['message']).to_not eql 'Queued. Thank you.'
      end

      it 'does not have a message id' do
        expect(@response['id']).to be_nil
      end
    end
  end

  describe '.sent?' do
    before(:each) { @mailgun = Adapters::Mailgun.new(input) }
    it 'returns true if id is present' do
      @mailgun.stub(id: 'mailgun_id')
      expect(@mailgun.sent?).to eql true
    end

    it 'returns false if id is blank' do
      @mailgun.stub(id: nil)
      expect(@mailgun.sent?).to eql false
    end
  end

  describe '.id' do
    it 'returns the response id' do
      mailgun = Adapters::Mailgun.new(input)
      mailgun.response = {'id' => 'mailgun_id'}
      expect(mailgun.id).to eql 'mailgun_id'
    end
  end

  describe '.error' do
    before(:each) { @mailgun = Adapters::Mailgun.new(input) }

    it 'is set to the response message' do
      @mailgun.response = {'id' => 'mailgun_id', 'message' => 'not an error message'}
      expect(@mailgun.error).to be_nil
    end

    it 'is nil if there is an id' do
      @mailgun.response = {'message' => 'error message'}
      expect(@mailgun.error).to eql 'error message'
    end
  end

  def input
    { 'to'        => ENV['MAILGUN_SANDBOX_EMAIL'],
      'to_name'   => "Mr. Fake",
      'from'      => "noreply@mybrightwheel.com",
      'from_name' => "Brightwheel",
      'subject'   => "A Message from Brightwheel",
      'body'      => "Your Bill is $10"
    }
  end

end
