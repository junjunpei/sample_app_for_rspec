FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "Task #{n}" }
    content { "content" }
    status { "todo" }
    deadline { 1.day.from_now }
    association :user
  end
end
