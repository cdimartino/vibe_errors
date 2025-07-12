module VibeErrors
  class MessageTag < ApplicationRecord
    self.table_name = "vibe_errors_message_tags"

    belongs_to :message, class_name: "VibeErrors::Message"
    belongs_to :tag, class_name: "VibeErrors::Tag"

    validates :message_id, uniqueness: {scope: :tag_id}
  end
end
