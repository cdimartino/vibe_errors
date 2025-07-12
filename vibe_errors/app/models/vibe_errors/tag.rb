module VibeErrors
  class Tag < ApplicationRecord
    self.table_name = "vibe_errors_tags"

    has_many :error_tags, dependent: :destroy
    has_many :errors, through: :error_tags

    has_many :message_tags, dependent: :destroy
    has_many :messages, through: :message_tags

    validates :name, presence: true, uniqueness: {case_sensitive: false}
    validates :color, format: {with: /\A#[0-9a-f]{6}\z/i}, allow_nil: true

    scope :by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }
    scope :popular, -> { joins(:errors).group(:id).order("COUNT(vibe_errors_errors.id) DESC") }

    before_save :normalize_name

    def self.find_or_create_by_name(name)
      find_or_create_by(name: name.downcase.strip)
    end

    def usage_count
      errors.count + messages.count
    end

    def error_count
      errors.count
    end

    def message_count
      messages.count
    end

    private

    def normalize_name
      self.name = name.downcase.strip if name.present?
    end
  end
end
