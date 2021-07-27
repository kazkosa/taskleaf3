require 'rails_helper'
describe 'AdminManagers', type: :system  do

  let(:manager) {
    Manager.create(login_id: 'admin_test', admin: 1, password:'password', password_confirmation:'password')
  }

  it "Display Admin managers" do
    visit admin_login_path
    fill_in 'session[login_id]',    with: manager.login_id
    fill_in 'session[password]', with: manager.password
    click_button 'submit'
    expect(current_path).to eq admin_path

    expect(page).to have_link 'Magnagers', href: admin_managers_path
    click_link 'Magnagers'
    expect(current_path).to eq admin_managers_path
  end

end