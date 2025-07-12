FactoryBot.define do
  factory :vibe_errors_file_pattern, class: "VibeErrors::FilePattern" do
    association :owner, factory: :vibe_errors_owner
    pattern { "app/controllers/*.rb" }
    description { "All controller files" }
    active { true }

    trait :model_pattern do
      pattern { "app/models/*.rb" }
      description { "All model files" }
    end

    trait :service_pattern do
      pattern { "app/services/*.rb" }
      description { "All service files" }
    end

    trait :specific_file do
      pattern { "app/controllers/users_controller.rb" }
      description { "Users controller" }
    end

    trait :inactive do
      active { false }
    end
  end
end
