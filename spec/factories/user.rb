# encoding: utf-8
FactoryGirl.define do
	factory :user, class: 'Spree::User' do
		sequence(:login) { |n| "foo00000_1#{n}" }
		password "foobar"
		email { "#{login}@example.com" }
  end
 

  
end
