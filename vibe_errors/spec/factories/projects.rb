FactoryBot.define do
  factory :vibe_errors_project, class: "VibeErrors::Project" do
    sequence(:name) { |n| "Project #{n}" }
    sequence(:slug) { |n| "project-#{n}" }
    description { "A development project" }
    association :team, factory: :vibe_errors_team
    active { true }
    repository_url { "https://github.com/example/project" }
    environment { "production" }
    metadata { {language: "ruby", framework: "rails"} }

    trait :inactive do
      active { false }
    end

    trait :development do
      environment { "development" }
    end

    trait :staging do
      environment { "staging" }
    end

    trait :with_errors do
      after(:create) do |project|
        create_list(:vibe_errors_error, 5, project: project)
      end
    end
  end
end
