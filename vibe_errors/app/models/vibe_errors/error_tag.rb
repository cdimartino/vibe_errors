module VibeErrors
  class ErrorTag < ApplicationRecord
    self.table_name = "vibe_errors_error_tags"

    belongs_to :error, class_name: "VibeErrors::Error"
    belongs_to :tag, class_name: "VibeErrors::Tag"

    validates :error_id, uniqueness: {scope: :tag_id}
  end
end
