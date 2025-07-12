FactoryBot.define do
  factory :vibe_errors_error, class: "VibeErrors::Error" do
    message { "Something went wrong" }
    exception_class { "StandardError" }
    stack_trace { "app/controllers/application_controller.rb:10:in `index'\napp/models/user.rb:25:in `find_user'" }
    location { "app/controllers/application_controller.rb:10" }
    severity { "medium" }
    status { "new" }
    priority { "medium" }
    occurred_at { Time.current }
    occurrence_count { 1 }
    checksum { Digest::MD5.hexdigest("#{exception_class}:#{message}") }
    context { {controller: "application", action: "index"}.to_json }
    metadata { {user_id: 123, request_id: "abc123"} }

    association :owner, factory: :vibe_errors_owner, strategy: :build
    association :team, factory: :vibe_errors_team, strategy: :build
    association :project, factory: :vibe_errors_project, strategy: :build

    trait :critical do
      severity { "critical" }
      priority { "critical" }
    end

    trait :high_priority do
      priority { "high" }
    end

    trait :resolved do
      status { "resolved" }
      resolved_at { 1.hour.ago }
      resolution { "Fixed by updating the code" }
    end

    trait :in_progress do
      status { "in_progress" }
    end

    trait :ignored do
      status { "ignored" }
    end

    trait :with_tags do
      after(:create) do |error|
        error.tags << create_list(:vibe_errors_tag, 2)
      end
    end

    trait :with_due_date do
      due_date { 3.days.from_now }
    end

    trait :database_error do
      message { "PG::ConnectionBad: connection to server was lost" }
      exception_class { "PG::ConnectionBad" }
      stack_trace { "app/models/user.rb:10:in `find'\nvendor/bundle/gems/pg-1.0.0/lib/pg.rb:45" }
      location { "app/models/user.rb:10" }
      severity { "high" }
    end

    trait :api_timeout do
      message { "Net::ReadTimeout: Net::ReadTimeout" }
      exception_class { "Net::ReadTimeout" }
      stack_trace { "app/services/external_api_service.rb:25:in `call'\nlib/http_client.rb:10" }
      location { "app/services/external_api_service.rb:25" }
      severity { "medium" }
    end
  end
end
