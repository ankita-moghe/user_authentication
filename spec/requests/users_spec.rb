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

  describe "#verify_token_for_login" do
    let(:api_key) { create(:api_key)}
    let(:user) {create(:user)}
    let(:user_token) {user.generate_token}
    let(:verify_params) do {
        email: user.email,
        token: user_token
      }
    end

    context "When valid token passed" do
      it "should allow user to login" do
        request.headers["Api-key"] = api_key.key
        put :verify_token_for_login, params: {user: verify_params }
        expect(response).to have_http_status(:ok)
      end
    end

    context "When invalid token passed" do
      it "should not allow user to log in" do
        request.headers["Api-key"] = api_key.key
        verify_params[:token] = "wer34545"
        put :verify_token_for_login, params: {user: verify_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "#update" do
    let(:api_key) { create(:api_key)}
    let(:user) {create(:user)}
    let(:session) {Session.create(secret_id: "Mk3-iODjP3mnblur", user_id: user.id)}
    let(:update_params) do {
        first_name: "fsdvgsdfh",
        last_name: "gdfghftytte",
        two_factor_enabled: false
      }
    end
    context "When valid params passed" do
      context "when 2 factor is disabling" do
        it "should allow to update the user data" do
          request.headers["Api-key"] = api_key.key
          put :update, params: {id: session.secret_id, user: update_params }
          expect(response).to have_http_status(:ok)
        end
      end

      context "When enabling 2 factor authentication" do
        it "should send mail with token" do
          request.headers["Api-key"] = api_key.key
          update_params[:two_factor_enabled] = true
          put :update, params: {id: session.secret_id, user: update_params }
          expect(response).to have_http_status(:ok)
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
    end
  end
end
