require "rails_helper"

RSpec.describe VibeErrors do
  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(described_class.configuration).to be_a(VibeErrors::Configuration)
    end

    it "returns the same instance on multiple calls" do
      config1 = described_class.configuration
      config2 = described_class.configuration

      expect(config1).to be(config2)
    end
  end

  describe ".configure" do
    it "yields the configuration for customization" do
      described_class.configure do |config|
        config.auto_capture_errors = false
        config.default_error_severity = "high"
      end

      expect(described_class.configuration.auto_capture_errors).to be false
      expect(described_class.configuration.default_error_severity).to eq("high")
    end
  end

  describe ".reset_configuration!" do
    it "resets configuration to defaults" do
      described_class.configure do |config|
        config.auto_capture_errors = false
      end

      described_class.reset_configuration!

      expect(described_class.configuration.auto_capture_errors).to be true
    end
  end

  describe ".capture_exception" do
    let(:exception) { StandardError.new("Test error") }

    context "when error capturing is enabled" do
      before do
        allow(described_class.configuration).to receive(:should_capture_errors?).and_return(true)
        allow(described_class.configuration).to receive(:should_ignore_exception?).and_return(false)
      end

      it "creates an error from the exception" do
        expect(VibeErrors::Error).to receive(:from_exception).with(exception, {})

        described_class.capture_exception(exception)
      end

      it "passes options to from_exception" do
        options = {severity: "critical"}
        expect(VibeErrors::Error).to receive(:from_exception).with(exception, options)

        described_class.capture_exception(exception, options)
      end
    end

    context "when error capturing is disabled" do
      before do
        allow(described_class.configuration).to receive(:should_capture_errors?).and_return(false)
      end

      it "does not create an error" do
        expect(VibeErrors::Error).not_to receive(:from_exception)

        result = described_class.capture_exception(exception)
        expect(result).to be_nil
      end
    end

    context "when exception should be ignored" do
      before do
        allow(described_class.configuration).to receive(:should_capture_errors?).and_return(true)
        allow(described_class.configuration).to receive(:should_ignore_exception?).and_return(true)
      end

      it "does not create an error" do
        expect(VibeErrors::Error).not_to receive(:from_exception)

        result = described_class.capture_exception(exception)
        expect(result).to be_nil
      end
    end
  end

  describe ".capture_message" do
    let(:content) { "Test message" }

    context "when error capturing is enabled" do
      before do
        allow(described_class.configuration).to receive(:should_capture_errors?).and_return(true)
      end

      it "creates a message" do
        expect(VibeErrors::Message).to receive(:create_from_message).with(content, {})

        described_class.capture_message(content)
      end

      it "passes options to create_from_message" do
        options = {severity: "warning"}
        expect(VibeErrors::Message).to receive(:create_from_message).with(content, options)

        described_class.capture_message(content, options)
      end
    end

    context "when error capturing is disabled" do
      before do
        allow(described_class.configuration).to receive(:should_capture_errors?).and_return(false)
      end

      it "does not create a message" do
        expect(VibeErrors::Message).not_to receive(:create_from_message)

        result = described_class.capture_message(content)
        expect(result).to be_nil
      end
    end
  end

  describe ".log_error" do
    it "captures message with error severity and type" do
      expect(described_class).to receive(:capture_message).with(
        "Error message",
        severity: "error",
        message_type: "error"
      )

      described_class.log_error("Error message")
    end

    it "merges additional options" do
      expect(described_class).to receive(:capture_message).with(
        "Error message",
        severity: "error",
        message_type: "error",
        context: "test"
      )

      described_class.log_error("Error message", context: "test")
    end
  end

  describe ".log_warning" do
    it "captures message with warning severity and type" do
      expect(described_class).to receive(:capture_message).with(
        "Warning message",
        severity: "warning",
        message_type: "warning"
      )

      described_class.log_warning("Warning message")
    end
  end

  describe ".log_info" do
    it "captures message with info severity and type" do
      expect(described_class).to receive(:capture_message).with(
        "Info message",
        severity: "info",
        message_type: "info"
      )

      described_class.log_info("Info message")
    end
  end
end
