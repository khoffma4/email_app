require 'rails_helper'

describe EmailsController, :type => :controller do
  describe "POST create" do
    context 'when params are valid' do

      it 'returns a successful response' do
        post :create, params: valid_params
        expect(response.status).to eq(200)
      end

      it 'delivers the email' do
        expect_any_instance_of(SendEmail).to receive(:deliver)
        post :create, params: valid_params
      end

      it "includes the email sent as json" do
        post :create, params: valid_params
        json_response = JSON.parse(response.body)

        expect(json_response['email_client']).to eql ENV['EMAIL_CLIENT']
      end
    end

    context 'when params are not valid' do
      it 'returns a 401 error' do
        post :create, params: {}
        expect(response.status).to eq(422)
      end

      it 'contains error messages' do
        post :create, params: valid_params.except('to')
        errors = JSON.parse(response.body)['errors']
        expect(errors['to']).to include "can't be blank"
      end
    end
  end

  def valid_params
    { 'to'        => "fake@example.com",
      'to_name'   => "Mr. Fake",
      'from'      => "noreply@mybrightwheel.com",
      'from_name' => "Brightwheel",
      'subject'   => "A Message from Brightwheel",
      'body'      => "<h1>Your Bill</h1><p>$10</p>" }
  end
end
