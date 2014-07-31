require 'spec_helper'

describe User do
  describe "validating" do
    describe "creating a new user" do
      before { subject.valid? }

      it 'needs a first_name' do
        expect(subject.errors[:first_name]).to include("can't be blank")
      end

      it 'needs a last_name' do
        expect(subject.errors[:last_name]).to include("can't be blank")
      end

      it 'needs an email' do
        expect(subject.errors[:email]).to include("can't be blank")
      end

      describe 'username' do
        it "can't be blank" do
          expect(subject.errors[:username]).to include("can't be blank")
        end

        it "must be unique" do
          user = existing_user
          user.save!
          subject.username = user.username
          subject.valid?
          expect(subject.errors[:username]).to include("has already been taken")
        end
      end

      it 'needs an encrypted_password' do
        expect(subject.errors[:encrypted_password]).to include("can't be blank")
      end

      it 'must have a password that matches confirmation' do
        user = User.new(password: 'foo', password_confirmation: 'bar')
        user.valid?
        expect(user.errors[:password_confirmation]).to include("doesn't match Password")
      end

      context 'when there is no auth_token' do
        it 'does not need a token_set time' do
          subject.auth_token = ''
          subject.valid?
          expect(subject.errors[:token_set]).not_to include("can't be blank")
        end
      end

      context 'when there is an auth_token' do
        it 'needs a token_set time' do
          subject.auth_token = 'sdsdja'
          subject.valid?
          expect(subject.errors[:token_set]).to include("can't be blank")
        end
      end
    end

    describe "updating an existing user's details" do
      subject { existing_user }

      it 'needs a first_name' do
        subject.first_name = ''
        expect(subject).to be_invalid
        expect(subject.errors[:first_name]).to include("can't be blank")
      end

      it 'needs a last_name' do
        subject.last_name = ''
        expect(subject).to be_invalid
        expect(subject.errors[:last_name]).to include("can't be blank")
      end

      it 'needs an email' do
        subject.email = ''
        expect(subject).to be_invalid
        expect(subject.errors[:email]).to include("can't be blank")
      end

      it 'does not need a password_confirmation when password is nil' do
        subject.password = nil
        expect(subject).to be_valid
        expect(subject.errors[:password_confirmation]).not_to include("doesn't match Password")
      end

      it 'does not need a password_confirmation when password is blank' do
        subject.password = ''
        expect(subject).to be_valid
        expect(subject.errors[:password_confirmation]).not_to include("doesn't match Password")
      end

      it 'needs a password_confirmation when password is given' do
        subject.password = 'foo'
        expect(subject).to be_invalid
        expect(subject.errors[:password_confirmation]).to include("doesn't match Password")
      end

      context 'when there is no auth_token' do
        it 'does not need a token_set time' do
          subject.auth_token = ''
          subject.valid?
          expect(subject.errors[:token_set]).not_to include("can't be blank")
        end
      end

      context 'when there is an auth_token' do
        it 'needs a token_set time' do
          subject.auth_token = 'sdsdja'
          subject.valid?
          expect(subject.errors[:token_set]).to include("can't be blank")
        end
      end
    end
  end

  describe 'encrypting the password' do
    it "does not encrypt a password if no password is given" do
      subject.valid?
      expect(subject.encrypted_password).to be_nil
    end

    it "does not encrypt a password if password doesn't match confirmation" do
      subject.password = 'foo'
      subject.valid?
      expect(subject.encrypted_password).to be_nil
    end

    it 'encrypts a password if password is given and matches confirmation' do
      subject.password = 'foo'
      subject.password_confirmation = 'foo'
      subject.valid?
      expect(subject.encrypted_password).not_to be_nil
    end
  end

  describe 'authenticating by username and password' do
    context 'when given username does not exist' do
      it 'raises an error' do
        expect{User.authenticate!('bobbyt', 'password')}.to raise_error('Invalid username or password')
      end
    end

    context 'when given username does exist' do
      let(:user) { existing_user }

      before :each do
        user.save!
      end

      it 'raises an error if the password is wrong' do
        expect{User.authenticate!('bobbyt', 'wrong')}.to raise_error('Invalid username or password')
      end

      it 'returns the user if the password is correct' do
        expect(User.authenticate!('bobbyt', 'password')).to eql(user)
      end
    end
  end

  describe 'authenticating by token' do
    it 'is nil if no user matches token' do
      expect(User.get_with_token('does-not-exist')).to be_nil
    end

    it 'returns the user if user matches token' do
      user = existing_user
      user.save!
      user.login!
      expect(user.auth_token).not_to be_nil
      expect(User.get_with_token(user.auth_token)).to eql(user)
    end
  end

  describe 'starting and finishing a session' do
    let(:mock_token) { 'ghjhghjk' }
    let(:mock_time)  { Time.new('2014-05-04 13:37') }

    subject { existing_user }

    before :each do
      allow(subject).to receive(:save!)
    end

    describe 'logging in' do
      it 'sets the auth token' do
        allow(SecureRandom).to receive(:hex).and_return(mock_token)
        expect(subject.auth_token).to be_nil
        subject.login!
        expect(subject.auth_token).to eql(mock_token)
      end

      it 'sets the token_set to be now' do
        Timecop.freeze(mock_time) do
          expect(subject.token_set).to be_nil
          subject.login!
          expect(subject.token_set.to_s(:short)).to eq(Time.now.to_s(:short))
        end
      end
    end

    describe 'logging out' do
      it 'removes the auth token' do
        subject.auth_token = mock_token
        expect(subject.auth_token).to eql(mock_token)
        subject.logout!
        expect(subject.auth_token).to be_nil
      end

      it 'sets the token_set to be now' do
        subject.token_set = mock_time
        expect(subject.token_set.to_s(:short)).to eql(mock_time.to_s(:short))
        subject.logout!
        expect(subject.token_set).to be_nil
      end
    end

    describe 'logged_in?' do
      let(:user) { existing_user }

      it 'is false if the user is not logged in' do
        expect(user).not_to be_logged_in
      end

      it 'is true if the user logs in' do
        user.login!
        expect(user).to be_logged_in
      end

      it 'is false if the user logs in then logs out' do
        user.login!
        user.logout!
        expect(user).not_to be_logged_in
      end
    end
  end
end

require 'bcrypt'
include BCrypt

def existing_user
  User.new(
    first_name: 'Bobby',
    last_name: 'Tables',
    username: 'bobbyt',
    email: 'bobby@example.com',
    encrypted_password: Password.create('password')
  )
end
