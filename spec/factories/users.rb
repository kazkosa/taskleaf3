FactoryBot.define do
  factory :user do
    name                  {"abe"}
    email                 {"aaa@gmail.com"}
    password              {"foobar"}
    password_confirmation {"foobar"}
  end
end