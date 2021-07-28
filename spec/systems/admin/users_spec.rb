require 'rails_helper'
describe 'AdminUsers', type: :system  do

  let(:manager) {
    Manager.create(login_id: 'admin_test', admin: 1, password:'password', password_confirmation:'password')
  }
  let(:user) { FactoryBot.create(:user) }

  it "Display Admin users" do
    visit admin_login_path
    fill_in 'session[login_id]',    with: manager.login_id
    fill_in 'session[password]', with: manager.password
    click_button 'submit'
    expect(current_path).to eq admin_path
    expect(page).to have_link 'Users', href: admin_users_path
    click_link 'Users'
    expect(current_path).to eq admin_users_path
  end

  it "Create User by Admin manager" do
    visit admin_login_path
    fill_in 'session[login_id]',    with: manager.login_id
    fill_in 'session[password]', with: manager.password
    click_button 'submit'
    expect(current_path).to eq admin_path
    expect(page).to have_link 'Users', href: admin_users_path
    click_link 'Users'
    expect(current_path).to eq admin_users_path
    expect(page).to have_link 'New', href: new_admin_user_path
    click_link 'New'
    expect(current_path).to eq new_admin_user_path
    fill_in 'user[name]', with: 'test_user'
    fill_in 'user[email]', with: 'example@mail.com'
    find("#user_admin").find("option[value='0']").select_option
    find("#user_activated").find("option[value='1']").select_option
    fill_in 'user[password]', with: 'password'
    fill_in 'user[password_confirmation]', with: 'password'
    click_button 'Create'
    expect(page).to have_content('Create User Success!')
  end

end