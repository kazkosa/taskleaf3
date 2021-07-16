FactoryBot.define do
  factory :user do
    name                  {"abe"}
    email                 {"abe@gmail.com"}
    password              {"foobar"}
    password_confirmation {"foobar"}
  end
end