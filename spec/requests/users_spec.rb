require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "#log_in" do
    let(:api_key) { create(:api_key)}
    let(:user) {create(:user)}
    let(:login_params) do {
        user: {
          email: user.email,
          password: user.password
        }
      }
    end

    context "With valid user email and password" do
      context "When 2 factor disabled" do
        it "Should allow user to login" do
          request.headers["Api-key"] = api_key.key
          post :login, params: login_params
          expect(response).to have_http_status(:ok)
        end
      end

      context "When 2 factor enabled" do
        it "should send token to login" do
          user.update(two_factor_enabled: true)
          request.headers["Api-key"] = api_key.key
          post :login, params: login_params
          expect(response).to have_http_status(:ok)
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
    end

    context "With invalid email and password" do
      it "should fail the api" do
        request.headers["Api-key"] = api_key.key
        login_params[:user][:password] = "rwqetert123453"
        post :login, params: login_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "#update_password" do
    let(:api_key) { create(:api_key)}
    let(:user) {create(:user)}
    let(:update_params) do {
        password: user.password,
        new_password: "12345rft"
      }
    end

    let(:session) {Session.create(secret_id: "Mk3-iODjP3mnblur", user_id: user.id)}
    context "With valid password" do
      it "should update the new password" do
        request.headers["Api-key"] = api_key.key
        patch :update_password, params: {id: session.secret_id, user: update_params }
        expect(response).to have_http_status(:ok)
      end
    end

    context "With wrong password" do
      it "should not allow to update the password" do
        request.headers["Api-key"] = api_key.key
        update_params[:password] = "1234"
        patch :update_password, params: {id: session.secret_id, user: update_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
