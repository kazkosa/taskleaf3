require 'rails_helper'
describe 'AdminSessions', type: :system  do

  let(:manager) {
    Manager.create(login_id: 'admin_test', admin: 1, password:'password', password_confirmation:'password')
  }

  it "Admin login with invalid information" do
    visit admin_login_path
    fill_in 'session[login_id]', with: manager.login_id
    fill_in 'session[password]', with: ''
    click_button 'submit'
    expect(current_path).to eq admin_login_path
  end

  it "Admin login with valid information" do
    visit admin_login_path
    fill_in 'session[login_id]',    with: manager.login_id
    fill_in 'session[password]', with: manager.password
    click_button 'submit'
    expect(current_path).to eq admin_path
  end

  it "Admin login with valid information followed by logout" do
    visit admin_login_path
    fill_in 'session[login_id]',    with: manager.login_id
    fill_in 'session[password]', with: manager.password
    click_button 'submit'
    expect(current_path).to eq admin_path
    expect(page).to have_link 'Logout', href: admin_logout_path
    click_link 'Logout'
    expect(current_path).to eq root_path
  end

end