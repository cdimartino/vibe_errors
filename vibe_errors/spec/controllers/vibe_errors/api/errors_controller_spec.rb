require "rails_helper"

RSpec.describe VibeErrors::Api::ErrorsController, type: :controller do
  routes { VibeErrors::Engine.routes }

  describe "GET #index" do
    let!(:errors) { create_list(:vibe_errors_error, 3) }

    it "returns a list of errors" do
      get :index, format: :json

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]).to be_an(Array)
      expect(json_response["errors"].length).to eq(3)
    end

    it "includes pagination metadata" do
      get :index, format: :json

      json_response = JSON.parse(response.body)
      expect(json_response["meta"]).to include("current_page", "per_page", "total_pages", "total_count")
    end

    it "filters by severity" do
      critical_error = create(:vibe_errors_error, severity: "critical")

      get :index, params: {severity: "critical"}, format: :json

      json_response = JSON.parse(response.body)
      expect(json_response["errors"].length).to eq(1)
      expect(json_response["errors"].first["id"]).to eq(critical_error.id)
    end

    it "filters by status" do
      resolved_error = create(:vibe_errors_error, :resolved)

      get :index, params: {status: "resolved"}, format: :json

      json_response = JSON.parse(response.body)
      expect(json_response["errors"].length).to eq(1)
      expect(json_response["errors"].first["id"]).to eq(resolved_error.id)
    end

    it "searches by query" do
      searchable_error = create(:vibe_errors_error, message: "unique search term")

      get :index, params: {q: "unique search"}, format: :json

      json_response = JSON.parse(response.body)
      expect(json_response["errors"].length).to eq(1)
      expect(json_response["errors"].first["id"]).to eq(searchable_error.id)
    end
  end

  describe "GET #show" do
    let(:error) { create(:vibe_errors_error, :with_tags) }

    it "returns the error details" do
      get :show, params: {id: error.id}, format: :json

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["error"]["id"]).to eq(error.id)
      expect(json_response["error"]["message"]).to eq(error.message)
      expect(json_response["error"]["stack_trace"]).to be_present
    end

    it "returns 404 for non-existent error" do
      get :show, params: {id: 99999}, format: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        error: {
          message: "Test error",
          exception_class: "StandardError",
          severity: "medium",
          status: "new"
        }
      }
    end

    it "creates a new error" do
      expect {
        post :create, params: valid_params, format: :json
      }.to change(VibeErrors::Error, :count).by(1)

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response["error"]["message"]).to eq("Test error")
    end

    it "adds tags if provided" do
      params_with_tags = valid_params.merge(tags: ["api", "database"])

      post :create, params: params_with_tags, format: :json

      json_response = JSON.parse(response.body)
      tag_names = json_response["error"]["tags"].map { |tag| tag["name"] }
      expect(tag_names).to include("api", "database")
    end

    it "returns validation errors for invalid data" do
      invalid_params = {error: {message: ""}}

      post :create, params: invalid_params, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]).to be_present
    end
  end

  describe "POST #create_from_exception" do
    let(:exception_params) do
      {
        exception: {
          message: "Database connection failed",
          exception_class: "PG::ConnectionBad",
          stack_trace: "app/models/user.rb:10\napp/controllers/users_controller.rb:25"
        },
        severity: "high",
        auto_assign_owner: true
      }
    end

    it "creates an error from exception data" do
      expect {
        post :create_from_exception, params: exception_params, format: :json
      }.to change(VibeErrors::Error, :count).by(1)

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response["error"]["message"]).to eq("Database connection failed")
      expect(json_response["error"]["exception_class"]).to eq("PG::ConnectionBad")
    end

    it "handles invalid exception data" do
      post :create_from_exception, params: {exception: {}}, format: :json

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "PATCH #resolve" do
    let(:error) { create(:vibe_errors_error, status: "new") }

    it "resolves the error" do
      patch :resolve, params: {id: error.id, resolution: "Fixed the bug"}, format: :json

      expect(response).to have_http_status(:ok)
      error.reload
      expect(error.status).to eq("resolved")
      expect(error.resolved_at).to be_present
      expect(error.resolution).to eq("Fixed the bug")
    end
  end

  describe "PATCH #assign_owner" do
    let(:error) { create(:vibe_errors_error) }
    let(:owner) { create(:vibe_errors_owner) }

    it "assigns an owner to the error" do
      patch :assign_owner, params: {id: error.id, owner_id: owner.id}, format: :json

      expect(response).to have_http_status(:ok)
      error.reload
      expect(error.owner).to eq(owner)
    end

    it "returns 404 for non-existent owner" do
      patch :assign_owner, params: {id: error.id, owner_id: 99999}, format: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST #add_tag" do
    let(:error) { create(:vibe_errors_error) }

    it "adds a tag to the error" do
      post :add_tag, params: {id: error.id, tag_name: "api"}, format: :json

      expect(response).to have_http_status(:ok)
      error.reload
      expect(error.tags.map(&:name)).to include("api")
    end
  end

  describe "DELETE #remove_tag" do
    let(:error) { create(:vibe_errors_error, :with_tags) }
    let(:tag) { error.tags.first }

    it "removes a tag from the error" do
      delete :remove_tag, params: {id: error.id, tag_name: tag.name}, format: :json

      expect(response).to have_http_status(:ok)
      error.reload
      expect(error.tags.map(&:name)).not_to include(tag.name)
    end
  end

  describe "PATCH #update" do
    let(:error) { create(:vibe_errors_error) }

    it "updates the error" do
      patch :update, params: {
        id: error.id,
        error: {severity: "critical", priority: "high"}
      }, format: :json

      expect(response).to have_http_status(:ok)
      error.reload
      expect(error.severity).to eq("critical")
      expect(error.priority).to eq("high")
    end
  end

  describe "DELETE #destroy" do
    let(:error) { create(:vibe_errors_error) }

    it "deletes the error" do
      expect {
        delete :destroy, params: {id: error.id}, format: :json
      }.to change(VibeErrors::Error, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
