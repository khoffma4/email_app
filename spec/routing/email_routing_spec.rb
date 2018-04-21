require 'rails_helper'

describe "Email Routes", :type => :routing do

  it 'routes post requests to "/emails" to the emails#create action' do
    expect(:post => "/email").to route_to('emails#create')
  end

end
