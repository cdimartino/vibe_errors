FactoryBot.define do
  factory :vibe_errors_owner, class: "VibeErrors::Owner" do
    sequence(:name) { |n| "Developer #{n}" }
    sequence(:email) { |n| "dev#{n}@example.com" }
    first_name { "John" }
    last_name { "Doe" }
    sequence(:github_username) { |n| "dev#{n}" }
    active { true }
    bio { "Experienced developer" }
    avatar_url { "https://github.com/#{github_username}.png" }
    metadata { {team: "backend", level: "senior"} }

    trait :inactive do
      active { false }
    end

    trait :with_teams do
      after(:create) do |owner|
        create_list(:vibe_errors_team_member, 2, owner: owner)
      end
    end

    trait :with_errors do
      after(:create) do |owner|
        create_list(:vibe_errors_error, 3, owner: owner)
      end
    end
  end
end
