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
