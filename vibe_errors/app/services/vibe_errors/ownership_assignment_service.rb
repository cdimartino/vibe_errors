require "shellwords"

module VibeErrors
  class OwnershipAssignmentService
    attr_reader :error, :stack_trace

    def initialize(error)
      @error = error
      @stack_trace = error.stack_trace
    end

    def assign_owner
      return unless stack_trace.present?

      owner = find_owner_from_stack_trace
      if owner
        error.update(owner: owner)
        owner
      end
    end

    private

    def find_owner_from_stack_trace
      # Parse stack trace to find application files
      app_files = extract_app_files_from_stack_trace
      return nil if app_files.empty?

      # Try different strategies to find owner
      find_owner_by_file_patterns(app_files) ||
        find_owner_by_git_blame(app_files) ||
        find_owner_by_code_ownership_rules(app_files) ||
        find_owner_by_directory_patterns(app_files)
    end

    def extract_app_files_from_stack_trace
      return [] unless stack_trace.present?

      lines = stack_trace.split("\n")

      # Extract file paths from stack trace lines
      app_files = lines.map do |line|
        # Match patterns like: /path/to/file.rb:123:in `method_name'
        if (match = line.match(/^([^:]+\.rb):(\d+):?/))
          {
            file_path: match[1],
            line_number: match[2].to_i,
            full_line: line
          }
        end
      end.compact

      # Filter to only include application files (not gems)
      app_files.select do |file_info|
        file_path = file_info[:file_path]
        file_path.include?("/app/") &&
          !file_path.include?("/gems/") &&
          !file_path.include?("/vendor/")
      end
    end

    def find_owner_by_file_patterns(app_files)
      app_files.each do |file_info|
        file_path = file_info[:file_path]

        # Check if there's a direct file pattern match
        owner = Owner.joins(:file_patterns)
          .where("file_patterns.pattern = ? OR ? LIKE file_patterns.pattern",
            file_path, file_path)
          .first

        return owner if owner
      end

      nil
    end

    def find_owner_by_git_blame(app_files)
      return nil unless git_available?

      app_files.each do |file_info|
        file_path = file_info[:file_path]
        line_number = file_info[:line_number]

        # Get git blame information for the specific line
        blame_info = get_git_blame_info(file_path, line_number)
        next unless blame_info

        # Find owner by git email
        owner = Owner.find_by(email: blame_info[:email])
        return owner if owner

        # Find owner by git name
        owner = Owner.find_by(name: blame_info[:name])
        return owner if owner
      end

      nil
    end

    def find_owner_by_code_ownership_rules(app_files)
      # Load CODEOWNERS file if it exists
      codeowners_rules = load_codeowners_rules
      return nil if codeowners_rules.empty?

      app_files.each do |file_info|
        file_path = file_info[:file_path]

        # Find matching rule from CODEOWNERS
        matching_rule = find_matching_codeowners_rule(file_path, codeowners_rules)
        next unless matching_rule

        # Find owner by email or username
        owner = find_owner_by_codeowners_rule(matching_rule)
        return owner if owner
      end

      nil
    end

    def find_owner_by_directory_patterns(app_files)
      app_files.each do |file_info|
        file_path = file_info[:file_path]

        # Extract directory components
        directory_parts = file_path.split("/")

        # Check for owner assignments based on directory structure
        # e.g., /app/controllers/admin/* -> admin team
        # e.g., /app/services/payment/* -> payment team

        if directory_parts.include?("controllers")
          controller_name = directory_parts.last&.gsub("_controller.rb", "")
          if controller_name
            owner = find_owner_by_controller_name(controller_name)
            return owner if owner
          end
        elsif directory_parts.include?("models")
          model_name = directory_parts.last&.gsub(".rb", "")
          if model_name
            owner = find_owner_by_model_name(model_name)
            return owner if owner
          end
        elsif directory_parts.include?("services")
          service_name = directory_parts.last&.gsub(".rb", "")
          if service_name
            owner = find_owner_by_service_name(service_name)
            return owner if owner
          end
        end
      end

      nil
    end

    def git_available?
      system("git --version > /dev/null 2>&1")
    end

    def get_git_blame_info(file_path, line_number)
      return nil unless File.exist?(file_path)

      begin
        blame_output = `git blame -L #{line_number.to_i},#{line_number.to_i} --porcelain #{Shellwords.escape(file_path)} 2>/dev/null`
        return nil if blame_output.empty?

        # Parse git blame porcelain output
        lines = blame_output.split("\n")
        author_line = lines.find { |line| line.start_with?("author ") }
        email_line = lines.find { |line| line.start_with?("author-mail ") }

        return nil unless author_line && email_line

        {
          name: author_line.sub("author ", ""),
          email: email_line.sub("author-mail ", "").gsub(/[<>]/, "")
        }
      rescue => e
        Rails.logger.warn("Failed to get git blame info for #{file_path}: #{e.message}")
        nil
      end
    end

    def load_codeowners_rules
      codeowners_paths = [
        ".github/CODEOWNERS",
        ".gitlab/CODEOWNERS",
        "CODEOWNERS"
      ]

      codeowners_paths.each do |path|
        full_path = Rails.root.join(path)
        if File.exist?(full_path)
          return parse_codeowners_file(full_path)
        end
      end

      []
    end

    def parse_codeowners_file(file_path)
      rules = []

      File.readlines(file_path).each do |line|
        line = line.strip
        next if line.empty? || line.start_with?("#")

        parts = line.split(/\s+/)
        next if parts.length < 2

        pattern = parts[0]
        owners = parts[1..]

        rules << {pattern: pattern, owners: owners}
      end

      rules
    end

    def find_matching_codeowners_rule(file_path, rules)
      # Find the most specific matching rule
      matching_rules = rules.select do |rule|
        File.fnmatch(rule[:pattern], file_path, File::FNM_PATHNAME)
      end

      # Return the last matching rule (most specific)
      matching_rules.last
    end

    def find_owner_by_codeowners_rule(rule)
      rule[:owners].each do |owner_identifier|
        # Remove @ symbol if present
        identifier = owner_identifier.delete("@")

        # Try to find by email first
        owner = Owner.find_by(email: "#{identifier}@#{default_email_domain}")
        return owner if owner

        # Try to find by GitHub username
        owner = Owner.find_by(github_username: identifier)
        return owner if owner

        # Try to find by name
        owner = Owner.find_by(name: identifier)
        return owner if owner
      end

      nil
    end

    def find_owner_by_controller_name(controller_name)
      # This is a simplified example - you'd implement your own logic
      # based on your team's conventions
      case controller_name
      when /admin/
        Team.find_by(name: "Admin")&.owners&.first
      when /api/
        Team.find_by(name: "API")&.owners&.first
      when /payment/
        Team.find_by(name: "Payment")&.owners&.first
      end
    end

    def find_owner_by_model_name(model_name)
      # Implement your own logic based on model ownership patterns
      nil
    end

    def find_owner_by_service_name(service_name)
      # Implement your own logic based on service ownership patterns
      nil
    end

    def default_email_domain
      # You can configure this based on your organization
      "example.com"
    end
  end
end
