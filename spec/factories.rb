FactoryBot.define do
  
  factory :api_key do
    key { "wNilVIIW2h7LwMbD" }
  end
  
  factory :user do
    first_name { "Joe" }
    email { "joe@gmail.com" }
    password { "blah567" }
  end
end