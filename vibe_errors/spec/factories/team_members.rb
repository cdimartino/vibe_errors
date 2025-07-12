FactoryBot.define do
  factory :vibe_errors_team_member, class: "VibeErrors::TeamMember" do
    association :team, factory: :vibe_errors_team
    association :owner, factory: :vibe_errors_owner
    role { "member" }
    joined_at { 1.month.ago }

    trait :lead do
      role { "lead" }
    end

    trait :admin do
      role { "admin" }
    end
  end
end
