require "rails_helper"

RSpec.describe VibeErrors::Error, type: :model do
  describe "associations" do
    it { should have_many(:error_tags).dependent(:destroy) }
    it { should have_many(:tags).through(:error_tags) }
    it { should belong_to(:owner).class_name("VibeErrors::Owner").optional }
    it { should belong_to(:team).class_name("VibeErrors::Team").optional }
    it { should belong_to(:project).class_name("VibeErrors::Project").optional }
  end

  describe "validations" do
    it { should validate_presence_of(:message) }
    it { should validate_presence_of(:severity) }
    it { should validate_inclusion_of(:severity).in_array(%w[low medium high critical]) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[new in_progress resolved ignored]) }
    it { should validate_inclusion_of(:priority).in_array(%w[low medium high critical]).allow_nil }
  end

  describe "scopes" do
    let!(:low_error) { create(:vibe_errors_error, severity: "low") }
    let!(:high_error) { create(:vibe_errors_error, severity: "high") }
    let!(:new_error) { create(:vibe_errors_error, status: "new") }
    let!(:resolved_error) { create(:vibe_errors_error, :resolved) }
    let!(:owner) { create(:vibe_errors_owner) }
    let!(:owned_error) { create(:vibe_errors_error, owner: owner) }

    it "filters by severity" do
      expect(described_class.by_severity("high")).to include(high_error)
      expect(described_class.by_severity("high")).not_to include(low_error)
    end

    it "filters by status" do
      expect(described_class.by_status("resolved")).to include(resolved_error)
      expect(described_class.by_status("resolved")).not_to include(new_error)
    end

    it "filters by owner" do
      expect(described_class.by_owner(owner.id)).to include(owned_error)
      expect(described_class.by_owner(owner.id)).not_to include(low_error)
    end

    it "orders by recent" do
      create(:vibe_errors_error, created_at: 1.day.ago)
      new_error = create(:vibe_errors_error, created_at: 1.hour.ago)

      expect(described_class.recent.first).to eq(new_error)
    end
  end

  describe ".from_exception" do
    let(:exception) do
      raise StandardError, "Test error"
    rescue => e
      e
    end

    it "creates an error from an exception" do
      error = described_class.from_exception(exception)

      expect(error).to be_persisted
      expect(error.message).to eq("Test error")
      expect(error.exception_class).to eq("StandardError")
      expect(error.stack_trace).to be_present
    end

    it "accepts options for severity and status" do
      error = described_class.from_exception(exception, severity: "critical", status: "in_progress")

      expect(error.severity).to eq("critical")
      expect(error.status).to eq("in_progress")
    end

    it "auto-assigns owner when option is set" do
      allow_any_instance_of(described_class).to receive(:assign_owner_from_stack_trace).and_return(true)

      error = described_class.from_exception(exception, auto_assign_owner: true)

      expect(error).to have_received(:assign_owner_from_stack_trace)
    end
  end

  describe ".extract_location_from_backtrace" do
    it "extracts app location from backtrace" do
      backtrace = [
        "/gems/activerecord/lib/active_record.rb:123",
        "/app/controllers/users_controller.rb:45",
        "/gems/rack/lib/rack.rb:67"
      ]

      location = described_class.extract_location_from_backtrace(backtrace)
      expect(location).to eq("/app/controllers/users_controller.rb:45")
    end

    it "returns first line if no app files found" do
      backtrace = [
        "/gems/activerecord/lib/active_record.rb:123",
        "/gems/rack/lib/rack.rb:67"
      ]

      location = described_class.extract_location_from_backtrace(backtrace)
      expect(location).to eq("/gems/activerecord/lib/active_record.rb:123")
    end

    it "returns nil for empty backtrace" do
      location = described_class.extract_location_from_backtrace([])
      expect(location).to be_nil
    end
  end

  describe "#assign_owner_from_stack_trace" do
    let(:error) { create(:vibe_errors_error, stack_trace: "app/controllers/users_controller.rb:10") }
    let(:service) { instance_double(VibeErrors::OwnershipAssignmentService) }

    before do
      allow(VibeErrors::OwnershipAssignmentService).to receive(:new).with(error).and_return(service)
    end

    it "uses the ownership assignment service" do
      allow(service).to receive(:assign_owner).and_return(nil)

      error.assign_owner_from_stack_trace

      expect(service).to have_received(:assign_owner)
    end

    it "logs successful assignment" do
      owner = create(:vibe_errors_owner)
      allow(service).to receive(:assign_owner).and_return(owner)
      allow(Rails.logger).to receive(:info)

      result = error.assign_owner_from_stack_trace

      expect(result).to eq(owner)
      expect(Rails.logger).to have_received(:info).with("Auto-assigned owner #{owner.name} to error #{error.id}")
    end

    it "logs failed assignment" do
      allow(service).to receive(:assign_owner).and_return(nil)
      allow(Rails.logger).to receive(:info)

      result = error.assign_owner_from_stack_trace

      expect(result).to be_nil
      expect(Rails.logger).to have_received(:info).with("Could not auto-assign owner for error #{error.id}")
    end
  end

  describe "#add_tag" do
    let(:error) { create(:vibe_errors_error) }
    let(:tag) { create(:vibe_errors_tag, name: "database") }

    it "adds a tag to the error" do
      error.add_tag("database")

      expect(error.tags.map(&:name)).to include("database")
    end

    it "creates a new tag if it does not exist" do
      expect {
        error.add_tag("new_tag")
      }.to change(VibeErrors::Tag, :count).by(1)

      expect(error.tags.map(&:name)).to include("new_tag")
    end

    it "does not add duplicate tags" do
      error.tags << tag

      expect {
        error.add_tag("database")
      }.not_to change(error.tags, :count)
    end

    it "normalizes tag names to lowercase" do
      error.add_tag("DATABASE")

      expect(error.tags.map(&:name)).to include("database")
    end
  end

  describe "#remove_tag" do
    let(:error) { create(:vibe_errors_error, :with_tags) }
    let(:tag) { error.tags.first }

    it "removes a tag from the error" do
      tag_name = tag.name

      error.remove_tag(tag_name)

      expect(error.tags.map(&:name)).not_to include(tag_name)
    end

    it "does nothing if tag is not associated" do
      expect {
        error.remove_tag("nonexistent")
      }.not_to change(error.tags, :count)
    end
  end

  describe "#resolved?" do
    it "returns true for resolved errors" do
      error = create(:vibe_errors_error, :resolved)
      expect(error.resolved?).to be true
    end

    it "returns false for non-resolved errors" do
      error = create(:vibe_errors_error, status: "new")
      expect(error.resolved?).to be false
    end
  end

  describe "#critical?" do
    it "returns true for critical errors" do
      error = create(:vibe_errors_error, severity: "critical")
      expect(error.critical?).to be true
    end

    it "returns false for non-critical errors" do
      error = create(:vibe_errors_error, severity: "low")
      expect(error.critical?).to be false
    end
  end

  describe "#high_priority?" do
    it "returns true for high priority errors" do
      error = create(:vibe_errors_error, priority: "high")
      expect(error.high_priority?).to be true
    end

    it "returns true for critical priority errors" do
      error = create(:vibe_errors_error, priority: "critical")
      expect(error.high_priority?).to be true
    end

    it "returns false for medium priority errors" do
      error = create(:vibe_errors_error, priority: "medium")
      expect(error.high_priority?).to be false
    end
  end
end
