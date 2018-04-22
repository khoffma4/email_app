class EmailsController < ApplicationController

  # POST /email
  def create
    email = SendEmail.new(email_params)

    if email.deliver
      render json: email.to_json, status: 200
    else
      render json: {errors: email.errors}, status: :unprocessable_entity
    end
  end

  private

  def email_params
    params.permit(
      :to, :to_name, :from, :from_name, :subject, :body
    )
  end

end
