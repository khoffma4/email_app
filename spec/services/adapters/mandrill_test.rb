require 'rails_helper'

describe Adapters::Mandrill do

  describe "#new" do
    it 'sets the "to" array' do
      mandrill = Adapters::Mandrill.new(input)
      expect(mandrill.to).to eql [{
        email: "fake@example.com",
        name: "Mr. Fake",
        type: 'to'
      }]
    end

    it 'sets the "text" field' do
      mandrill = Adapters::Mandrill.new(input)
      expect(mandrill.text).to eql "Your Bill is $10"
    end
  end

  describe '.email_json' do
    before(:all) do
      mandrill = Adapters::Mandrill.new(input)
      @json = JSON.parse mandrill.send(:email_json)
    end

    it 'includes the API key' do
      expect(@json['key']).to eql ENV['MANDRILL_API_KEY']
    end

    it 'contains the object json in the message key' do
      expect(@json['message']['from_email']).to eql "noreply@mybrightwheel.com"
    end
  end

  describe 'deliver' do
    context 'when the email is valid' do
      before(:all) do
        mandrill = Adapters::Mandrill.new(input)
        @response = mandrill.deliver
      end

      it "gets added to a queue" do
        expect(@response['status']).to eql 'queued'
      end

      it "does not have a reject reason" do
        expect(@response['reject_reason']).to be_nil
      end
    end

    context 'when the email is invalid' do
      before(:all) do
        mandrill = Adapters::Mandrill.new(input.except('from'))
        @response = mandrill.deliver
      end

      it 'gets rejected' do
        expect(@response['status']).to eql 'rejected'
      end

      it 'has a rejection reason' do
        expect(@response['reject_reason']).to eql 'invalid-sender'
      end
    end
  end

  def input
    { 'to'        => "fake@example.com",
      'to_name'   => "Mr. Fake",
      'from'      => "noreply@mybrightwheel.com",
      'from_name' => "Brightwheel",
      'subject'   => "A Message from Brightwheel",
      'body'      => "Your Bill is $10"
    }
  end

end
