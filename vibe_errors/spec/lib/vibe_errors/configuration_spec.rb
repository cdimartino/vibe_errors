require "rails_helper"

RSpec.describe VibeErrors::Configuration do
  let(:config) { described_class.new }

  describe "default values" do
    it "sets default auto_capture_errors to true" do
      expect(config.auto_capture_errors).to be true
    end

    it "sets default auto_assign_owners to true" do
      expect(config.auto_assign_owners).to be true
    end

    it "sets default error severity" do
      expect(config.default_error_severity).to eq("medium")
    end

    it "sets default message severity" do
      expect(config.default_message_severity).to eq("info")
    end

    it "sets default capture environments" do
      expect(config.capture_in_environments).to eq(%w[development test staging production])
    end

    it "sets default ignored exceptions" do
      expect(config.ignored_exceptions).to include(
        "ActionController::RoutingError",
        "ActionController::InvalidAuthenticityToken",
        "ActiveRecord::RecordNotFound"
      )
    end

    it "sets default retention policies" do
      expect(config.retain_resolved_errors_for).to eq(90)
      expect(config.retain_messages_for).to eq(30)
    end

    it "sets default pagination settings" do
      expect(config.default_per_page).to eq(25)
      expect(config.max_per_page).to eq(100)
    end
  end

  describe "#should_capture_errors?" do
    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(environment))
    end

    context "when auto_capture_errors is true and environment is included" do
      let(:environment) { "production" }

      it "returns true" do
        config.auto_capture_errors = true
        config.capture_in_environments = ["production"]

        expect(config.should_capture_errors?).to be true
      end
    end

    context "when auto_capture_errors is false" do
      let(:environment) { "production" }

      it "returns false" do
        config.auto_capture_errors = false
        config.capture_in_environments = ["production"]

        expect(config.should_capture_errors?).to be false
      end
    end

    context "when environment is not included" do
      let(:environment) { "development" }

      it "returns false" do
        config.auto_capture_errors = true
        config.capture_in_environments = ["production"]

        expect(config.should_capture_errors?).to be false
      end
    end
  end

  describe "#should_ignore_exception?" do
    it "returns true for ignored exception classes" do
      config.ignored_exceptions = ["StandardError"]
      exception = StandardError.new

      expect(config.should_ignore_exception?(exception)).to be true
    end

    it "returns true for ignored exception class names" do
      config.ignored_exceptions = ["StandardError"]

      expect(config.should_ignore_exception?(StandardError)).to be true
    end

    it "returns false for non-ignored exceptions" do
      config.ignored_exceptions = ["RuntimeError"]
      exception = StandardError.new

      expect(config.should_ignore_exception?(exception)).to be false
    end
  end

  describe "#should_notify_critical_error?" do
    it "returns true when notification is enabled and email is set" do
      config.notify_on_critical_errors = true
      config.notification_email = "admin@example.com"

      expect(config.should_notify_critical_error?).to be true
    end

    it "returns false when notification is disabled" do
      config.notify_on_critical_errors = false
      config.notification_email = "admin@example.com"

      expect(config.should_notify_critical_error?).to be false
    end

    it "returns false when email is not set" do
      config.notify_on_critical_errors = true
      config.notification_email = nil

      expect(config.should_notify_critical_error?).to be false
    end
  end
end
