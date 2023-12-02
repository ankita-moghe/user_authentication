require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "#log_in" do
    let(:api_key) { create(:api_key)}
    let(:user) {create(:user)}
    let(:login_params) do {
        email: user.email,
        password: user.password
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
    end

    context "With invalid email and password" do
      it "should fail the api" do
        request.headers["Api-key"] = api_key.key
        login_params[:password] = "rwqetert123453"
        post :login, params: login_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
