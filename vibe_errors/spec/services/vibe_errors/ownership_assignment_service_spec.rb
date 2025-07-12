require "rails_helper"

RSpec.describe VibeErrors::OwnershipAssignmentService do
  let(:error) { create(:vibe_errors_error, stack_trace: stack_trace) }
  let(:service) { described_class.new(error) }

  describe "#assign_owner" do
    context "with no stack trace" do
      let(:stack_trace) { nil }

      it "returns nil" do
        expect(service.assign_owner).to be_nil
      end
    end

    context "with empty stack trace" do
      let(:stack_trace) { "" }

      it "returns nil" do
        expect(service.assign_owner).to be_nil
      end
    end

    context "with valid stack trace" do
      let(:stack_trace) do
        "app/controllers/users_controller.rb:10:in `index'\n" \
        "app/models/user.rb:25:in `find_user'\n" \
        "/gems/activerecord/lib/active_record.rb:123"
      end

      it "attempts to find owner from stack trace" do
        expect(service).to receive(:find_owner_from_stack_trace).and_return(nil)
        service.assign_owner
      end
    end
  end

  describe "#extract_app_files_from_stack_trace" do
    let(:stack_trace) do
      "app/controllers/users_controller.rb:10:in `index'\n" \
      "app/models/user.rb:25:in `find_user'\n" \
      "/gems/activerecord/lib/active_record.rb:123\n" \
      "/vendor/bundle/gems/rack.rb:45"
    end

    it "extracts only application files" do
      app_files = service.send(:extract_app_files_from_stack_trace)

      expect(app_files.length).to eq(2)
      expect(app_files[0][:file_path]).to eq("app/controllers/users_controller.rb")
      expect(app_files[0][:line_number]).to eq(10)
      expect(app_files[1][:file_path]).to eq("app/models/user.rb")
      expect(app_files[1][:line_number]).to eq(25)
    end

    context "with no application files" do
      let(:stack_trace) do
        "/gems/activerecord/lib/active_record.rb:123\n" \
        "/vendor/bundle/gems/rack.rb:45"
      end

      it "returns empty array" do
        app_files = service.send(:extract_app_files_from_stack_trace)
        expect(app_files).to be_empty
      end
    end
  end

  describe "#find_owner_by_file_patterns" do
    let(:owner) { create(:vibe_errors_owner) }
    let(:file_pattern) { create(:vibe_errors_file_pattern, owner: owner, pattern: "app/controllers/*") }
    let(:app_files) do
      [{file_path: "app/controllers/users_controller.rb", line_number: 10}]
    end

    before do
      file_pattern # Ensure pattern is created
    end

    it "finds owner by file pattern" do
      result = service.send(:find_owner_by_file_patterns, app_files)
      expect(result).to eq(owner)
    end

    context "with no matching patterns" do
      let(:app_files) do
        [{file_path: "app/services/user_service.rb", line_number: 10}]
      end

      it "returns nil" do
        result = service.send(:find_owner_by_file_patterns, app_files)
        expect(result).to be_nil
      end
    end
  end

  describe "#git_available?" do
    it "checks if git is available" do
      allow(service).to receive(:system).with("git --version > /dev/null 2>&1").and_return(true)
      expect(service.send(:git_available?)).to be true
    end

    it "returns false when git is not available" do
      allow(service).to receive(:system).with("git --version > /dev/null 2>&1").and_return(false)
      expect(service.send(:git_available?)).to be false
    end
  end

  describe "#get_git_blame_info" do
    let(:file_path) { "app/controllers/users_controller.rb" }
    let(:line_number) { 10 }
    let(:blame_output) do
      "1234567890abcdef author John Doe\n" \
      "author-mail <john.doe@example.com>\n" \
      "author-time 1234567890\n"
    end

    before do
      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(service).to receive(:`).and_return(blame_output)
    end

    it "parses git blame output" do
      result = service.send(:get_git_blame_info, file_path, line_number)

      expect(result[:name]).to eq("John Doe")
      expect(result[:email]).to eq("john.doe@example.com")
    end

    context "when file does not exist" do
      before do
        allow(File).to receive(:exist?).with(file_path).and_return(false)
      end

      it "returns nil" do
        result = service.send(:get_git_blame_info, file_path, line_number)
        expect(result).to be_nil
      end
    end

    context "when git blame fails" do
      before do
        allow(service).to receive(:`).and_return("")
      end

      it "returns nil" do
        result = service.send(:get_git_blame_info, file_path, line_number)
        expect(result).to be_nil
      end
    end
  end

  describe "#load_codeowners_rules" do
    let(:codeowners_content) do
      "# This is a comment\n" \
      "*.rb @ruby-team\n" \
      "app/controllers/ @backend-team @team-lead\n" \
      "\n" \
      "docs/ @docs-team"
    end

    before do
      allow(File).to receive(:exist?).and_return(false)
      allow(File).to receive(:exist?).with(Rails.root.join(".github/CODEOWNERS")).and_return(true)
      allow(File).to receive(:readlines).and_return(codeowners_content.lines)
    end

    it "parses CODEOWNERS file" do
      rules = service.send(:load_codeowners_rules)

      expect(rules.length).to eq(3)
      expect(rules[0][:pattern]).to eq("*.rb")
      expect(rules[0][:owners]).to eq(["@ruby-team"])
      expect(rules[1][:pattern]).to eq("app/controllers/")
      expect(rules[1][:owners]).to eq(["@backend-team", "@team-lead"])
    end

    context "when no CODEOWNERS file exists" do
      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it "returns empty array" do
        rules = service.send(:load_codeowners_rules)
        expect(rules).to be_empty
      end
    end
  end

  describe "#find_matching_codeowners_rule" do
    let(:rules) do
      [
        {pattern: "*.rb", owners: ["@ruby-team"]},
        {pattern: "app/controllers/*", owners: ["@backend-team"]},
        {pattern: "app/controllers/admin/*", owners: ["@admin-team"]}
      ]
    end

    it "finds the most specific matching rule" do
      file_path = "app/controllers/admin/users_controller.rb"

      rule = service.send(:find_matching_codeowners_rule, file_path, rules)

      expect(rule[:pattern]).to eq("app/controllers/admin/*")
      expect(rule[:owners]).to eq(["@admin-team"])
    end

    it "finds general rule when specific does not match" do
      file_path = "app/controllers/users_controller.rb"

      rule = service.send(:find_matching_codeowners_rule, file_path, rules)

      expect(rule[:pattern]).to eq("app/controllers/*")
      expect(rule[:owners]).to eq(["@backend-team"])
    end
  end

  describe "#find_owner_by_codeowners_rule" do
    let(:rule) { {owners: ["@john.doe", "@backend-team"]} }
    let(:owner) { create(:vibe_errors_owner, email: "john.doe@example.com") }

    before do
      owner # Ensure owner is created
      allow(service).to receive(:default_email_domain).and_return("example.com")
    end

    it "finds owner by email domain" do
      result = service.send(:find_owner_by_codeowners_rule, rule)
      expect(result).to eq(owner)
    end

    context "with GitHub username" do
      let(:owner) { create(:vibe_errors_owner, github_username: "john.doe") }

      it "finds owner by GitHub username" do
        result = service.send(:find_owner_by_codeowners_rule, rule)
        expect(result).to eq(owner)
      end
    end

    context "with name" do
      let(:owner) { create(:vibe_errors_owner, name: "john.doe") }

      it "finds owner by name" do
        result = service.send(:find_owner_by_codeowners_rule, rule)
        expect(result).to eq(owner)
      end
    end
  end
end
