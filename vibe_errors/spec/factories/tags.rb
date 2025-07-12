FactoryBot.define do
  factory :vibe_errors_tag, class: "VibeErrors::Tag" do
    sequence(:name) { |n| "tag#{n}" }
    color { "##{SecureRandom.hex(3)}" }
    description { "A tag for categorizing" }
    metadata { {category: "general"} }

    trait :database do
      name { "database" }
      color { "#007bff" }
      description { "Database related issues" }
    end

    trait :api do
      name { "api" }
      color { "#28a745" }
      description { "API related issues" }
    end

    trait :security do
      name { "security" }
      color { "#dc3545" }
      description { "Security related issues" }
    end
  end
end
