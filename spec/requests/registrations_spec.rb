require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  describe "#create" do
    let(:api_key) { create(:api_key)}
    let(:create_params) do
      { user: {
          first_name: 'Ankita',
          last_name: 'moghe',
          email: 'ankita@example.com',
          password: 'ankita123',
          password_confirmation: 'ankita123'
        }
      }
    end

    context "With valid api key" do
      context "With valid user params" do
        it "should return success" do
          request.headers["Api-key"] = api_key.key
          post :create, params: create_params
          expect(response).to have_http_status(:created)
          user = User.last.reload
          expect(user.first_name).to eq('Ankita')
        end

        it "should send welcome email" do
          request.headers["Api-key"] = api_key.key
          post :create, params: create_params
          expect(response).to have_http_status(:created)
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end

      context "With invalid user params" do
        it "should return errors" do
          request.headers["Api-key"] = api_key.key
          create_params[:user][:email] = ""
          post :create, params: create_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "With invalid api key" do
      it "should fail the api" do
        request.headers["Api-key"] = 'asdfasdfasdfg'
        post :create, params: create_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
