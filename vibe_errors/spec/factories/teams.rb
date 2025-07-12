FactoryBot.define do
  factory :vibe_errors_team, class: "VibeErrors::Team" do
    sequence(:name) { |n| "Team #{n}" }
    sequence(:slug) { |n| "team-#{n}" }
    description { "A development team" }
    active { true }
    color { "##{SecureRandom.hex(3)}" }
    metadata { {type: "development", size: "small"} }

    trait :inactive do
      active { false }
    end

    trait :with_members do
      after(:create) do |team|
        create_list(:vibe_errors_team_member, 3, team: team)
      end
    end

    trait :with_projects do
      after(:create) do |team|
        create_list(:vibe_errors_project, 2, team: team)
      end
    end
  end
end
