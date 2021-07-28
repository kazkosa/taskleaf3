FactoryBot.define do
  factory :user do
    name                  {"abe"}
    email                 {"abe@gmail.com"}
    password              {"foobar"}
    password_confirmation {"foobar"}
    activated             {true}
    activated_at          {Time.zone.now}
  end
end