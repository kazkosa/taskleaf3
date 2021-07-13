require 'rails_helper'
describe User do
  describe '#create' do
    it "is valid with a name, email" do
      # user = User.new(name: "John Smith", email: "jsmith@mail.com")
      user = build(:user)
      expect(user).to be_valid
    end

    it "is invalid without a name" do
      # user = User.new(name: "", email: "jsmith@mail.com")
      user = build(:user, name:"")
      user.valid?
      expect(user.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a email" do
      # user = User.new(name: "John Smith", email: "")
      user = build(:user, email:"")
      user.valid?
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "is valid with a name that has less than 30 characters " do
      user = build(:user, name:"a"*30)
      expect(user).to be_valid
    end

    it "is invalid with a name that has more than 31 characters " do
      user = build(:user, name:"a"*31)
      user.valid?
      expect(user.errors[:name]).to include("is too long (maximum is 30 characters)")
    end

    it "is valid with a email that has less than 191 characters " do
      user = build(:user, email: "a"*179 + "@example.com")
      expect(user).to be_valid
    end

    it "is invalid with a email that has more than 192 characters " do
      user = build(:user, email: "a"*180 + "@example.com")
      user.valid?
      expect(user.errors[:email]).to include("is too long (maximum is 191 characters)")
    end

    it "is invalid with email that has invalid addresses" do
      user = build(:user)
      invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
      invalid_addresses.each do |invalid_address|
        user.email = invalid_address
        user.valid?
        expect(user.errors[:email]).to include("is invalid")
        # assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
      end
    end

    it "is invalid with a duplicate email address" do
      user = create(:user)
      another_user = build(:user)
      another_user.valid?
      expect(another_user.errors[:email]).to include("has already been taken")
    end

    it "email addresses should be saved as lower-case " do
      mixed_case_email = "Foo@ExAMPle.CoM"
      user = build(:user)
      user.email = "Foo@ExAMPle.CoM"
      user.save
      expect(mixed_case_email.downcase).to eq user.reload.email
    end

    it "password should be present (nonblank)" do
      user = build(:user)
      user.password = user.password_confirmation = " " * 6
      user.valid?
      expect(user.errors[:password]).to include("can't be blank")
    end

    it "password should have a minimum length" do
      user = build(:user)
      user.password = user.password_confirmation = "a" * 5
      user.valid?
      expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
    end


  end
end