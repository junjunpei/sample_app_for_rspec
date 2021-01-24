FactoryBot.define do
  factory :user do
    password { "foobar" }
    password_confirmation { "foobar" }
    sequence(:email) { |n| "tester#{n}@example.com"}
  end
end
