require 'rails_helper'
describe 'Session', type: :system  do

  let(:user) { FactoryBot.create(:user) }

  it "login with invalid information" do
    visit login_path
    fill_in 'session[email]',    with: user.email
    fill_in 'session[password]', with: ''
    click_button 'submit'
    expect(current_path).to eq login_path
  end

  it "login with valid information" do
    visit login_path
    fill_in 'session[email]',    with: user.email
    fill_in 'session[password]', with: user.password
    click_button 'submit'
    expect(current_path).to eq user_path(user)
  end

  it "login with valid information followed by logout" do
    visit login_path
    fill_in 'session[email]',    with: user.email
    fill_in 'session[password]', with: user.password
    click_button 'submit'
    expect(current_path).to eq user_path(user)
    expect(page).to have_link 'Log out', href: logout_path
    click_link 'Log out'
    expect(current_path).to eq root_path
  end
  
end