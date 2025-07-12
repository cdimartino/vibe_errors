FactoryBot.define do
  factory :vibe_errors_message, class: "VibeErrors::Message" do
    content { "User action completed successfully" }
    severity { "info" }
    message_type { "log" }
    context { "User performed action in controller" }
    metadata { {user_id: 123, session_id: "abc123", ip: "127.0.0.1"} }

    association :owner, factory: :vibe_errors_owner, strategy: :build
    association :team, factory: :vibe_errors_team, strategy: :build
    association :project, factory: :vibe_errors_project, strategy: :build

    trait :warning do
      severity { "warning" }
      message_type { "warning" }
      content { "Something might be wrong" }
    end

    trait :error do
      severity { "error" }
      message_type { "error" }
      content { "An error occurred but was handled" }
    end

    trait :critical do
      severity { "critical" }
      message_type { "error" }
      content { "Critical system failure detected" }
    end

    trait :debug do
      severity { "info" }
      message_type { "debug" }
      content { "Debug information for developers" }
    end

    trait :with_tags do
      after(:create) do |message|
        message.tags << create_list(:vibe_errors_tag, 2)
      end
    end
  end
end
