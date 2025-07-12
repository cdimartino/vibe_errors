require "rails_helper"

RSpec.describe VibeErrors::Message, type: :model do
  describe "associations" do
    it { should have_many(:message_tags).dependent(:destroy) }
    it { should have_many(:tags).through(:message_tags) }
    it { should belong_to(:owner).class_name("VibeErrors::Owner").optional }
    it { should belong_to(:team).class_name("VibeErrors::Team").optional }
    it { should belong_to(:project).class_name("VibeErrors::Project").optional }
  end

  describe "validations" do
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:severity) }
    it { should validate_inclusion_of(:severity).in_array(%w[info warning error critical]) }
    it { should validate_presence_of(:message_type) }
    it { should validate_inclusion_of(:message_type).in_array(%w[log debug info warning error]) }
  end

  describe "scopes" do
    let!(:info_message) { create(:vibe_errors_message, severity: "info") }
    let!(:error_message) { create(:vibe_errors_message, :error) }
    let!(:log_message) { create(:vibe_errors_message, message_type: "log") }
    let!(:debug_message) { create(:vibe_errors_message, :debug) }
    let!(:owner) { create(:vibe_errors_owner) }
    let!(:owned_message) { create(:vibe_errors_message, owner: owner) }

    it "filters by severity" do
      expect(described_class.by_severity("error")).to include(error_message)
      expect(described_class.by_severity("error")).not_to include(info_message)
    end

    it "filters by type" do
      expect(described_class.by_type("debug")).to include(debug_message)
      expect(described_class.by_type("debug")).not_to include(log_message)
    end

    it "filters by owner" do
      expect(described_class.by_owner(owner.id)).to include(owned_message)
      expect(described_class.by_owner(owner.id)).not_to include(info_message)
    end

    it "orders by recent" do
      create(:vibe_errors_message, created_at: 1.day.ago)
      new_message = create(:vibe_errors_message, created_at: 1.hour.ago)

      expect(described_class.recent.first).to eq(new_message)
    end
  end

  describe ".create_from_message" do
    it "creates a message from content" do
      message = described_class.create_from_message("Test message")

      expect(message).to be_persisted
      expect(message.content).to eq("Test message")
      expect(message.severity).to eq("info")
      expect(message.message_type).to eq("log")
    end

    it "accepts options for severity and type" do
      options = {severity: "error", message_type: "error", context: "test context"}
      message = described_class.create_from_message("Error message", options)

      expect(message.severity).to eq("error")
      expect(message.message_type).to eq("error")
      expect(message.context).to eq("test context")
    end

    it "assigns owner, team, and project from options" do
      owner = create(:vibe_errors_owner)
      team = create(:vibe_errors_team)
      project = create(:vibe_errors_project)

      options = {owner: owner, team: team, project: project}
      message = described_class.create_from_message("Test message", options)

      expect(message.owner).to eq(owner)
      expect(message.team).to eq(team)
      expect(message.project).to eq(project)
    end
  end

  describe "#add_tag" do
    let(:message) { create(:vibe_errors_message) }

    it "adds a tag to the message" do
      message.add_tag("api")

      expect(message.tags.map(&:name)).to include("api")
    end

    it "creates a new tag if it does not exist" do
      expect {
        message.add_tag("new_tag")
      }.to change(VibeErrors::Tag, :count).by(1)

      expect(message.tags.map(&:name)).to include("new_tag")
    end

    it "does not add duplicate tags" do
      tag = create(:vibe_errors_tag, name: "api")
      message.tags << tag

      expect {
        message.add_tag("api")
      }.not_to change(message.tags, :count)
    end
  end

  describe "#remove_tag" do
    let(:message) { create(:vibe_errors_message, :with_tags) }
    let(:tag) { message.tags.first }

    it "removes a tag from the message" do
      tag_name = tag.name

      message.remove_tag(tag_name)

      expect(message.tags.map(&:name)).not_to include(tag_name)
    end

    it "does nothing if tag is not associated" do
      expect {
        message.remove_tag("nonexistent")
      }.not_to change(message.tags, :count)
    end
  end

  describe "#critical?" do
    it "returns true for critical messages" do
      message = create(:vibe_errors_message, severity: "critical")
      expect(message.critical?).to be true
    end

    it "returns false for non-critical messages" do
      message = create(:vibe_errors_message, severity: "info")
      expect(message.critical?).to be false
    end
  end

  describe "#error?" do
    it "returns true for error severity" do
      message = create(:vibe_errors_message, severity: "error")
      expect(message.error?).to be true
    end

    it "returns true for error message type" do
      message = create(:vibe_errors_message, message_type: "error")
      expect(message.error?).to be true
    end

    it "returns false for info messages" do
      message = create(:vibe_errors_message, severity: "info", message_type: "info")
      expect(message.error?).to be false
    end
  end

  describe "#warning?" do
    it "returns true for warning severity" do
      message = create(:vibe_errors_message, severity: "warning")
      expect(message.warning?).to be true
    end

    it "returns true for warning message type" do
      message = create(:vibe_errors_message, message_type: "warning")
      expect(message.warning?).to be true
    end

    it "returns false for info messages" do
      message = create(:vibe_errors_message, severity: "info", message_type: "info")
      expect(message.warning?).to be false
    end
  end

  describe "#info?" do
    it "returns true for info severity" do
      message = create(:vibe_errors_message, severity: "info")
      expect(message.info?).to be true
    end

    it "returns true for info message type" do
      message = create(:vibe_errors_message, message_type: "info")
      expect(message.info?).to be true
    end

    it "returns false for error messages" do
      message = create(:vibe_errors_message, severity: "error", message_type: "error")
      expect(message.info?).to be false
    end
  end
end
