module VibeErrors
  class FilePattern < ApplicationRecord
    self.table_name = "vibe_errors_file_patterns"

    belongs_to :owner, class_name: "VibeErrors::Owner"

    validates :pattern, presence: true
    validates :pattern, uniqueness: {scope: :owner_id}

    scope :by_pattern, ->(pattern) { where("pattern LIKE ?", "%#{pattern}%") }
    scope :active, -> { where(active: true) }

    def matches?(file_path)
      File.fnmatch(pattern, file_path, File::FNM_PATHNAME)
    end

    def self.find_matching_patterns(file_path)
      active.select { |fp| fp.matches?(file_path) }
    end
  end
end
