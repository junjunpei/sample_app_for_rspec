require 'rails_helper'

RSpec.describe "Users", type: :system do
  let(:user) { create(:user) }

  describe 'ログイン前' do
    describe 'ユーザー新規登録' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの新規作成が成功する' do
          visit sign_up_path
          fill_in 'Email', with: 'foobar@example.com'
          fill_in 'Password', with: 'foobar'
          fill_in 'Password confirmation', with: 'foobar'
          click_button 'SignUp'
          expect(current_path).to eq login_path
          expect(page).to have_content 'User was successfully created.'
        end
      end
      context 'メールアドレスが未入力' do
        it 'ユーザーの新規作成が失敗する' do
          visit sign_up_path
          fill_in 'Email', with: nil
          fill_in 'Password', with: 'foobar'
          fill_in 'Password confirmation', with: 'foobar'
          click_button 'SignUp'
          expect(current_path).to eq users_path
          expect(page).to have_content '1 error prohibited this user from being saved'
          expect(page).to have_content "Email can't be blank"
        end
      end
      context '登録済のメールアドレスを使用' do
        it 'ユーザーの新規作成が失敗する' do
          existed_user = create(:user)
          visit sign_up_path
          fill_in 'Email', with: existed_user.email
          fill_in 'Password', with: 'foobar'
          fill_in 'Password confirmation', with: 'foobar'
          click_button 'SignUp'
          expect(current_path).to eq users_path
          expect(page).to have_content '1 error prohibited this user from being saved'
          expect(page).to have_content "Email has already been taken"
          expect(page).to have_field 'Email', with: existed_user.email
        end
      end
    end

    describe 'マイページ' do
      context 'ログインしていない状態' do
        it 'マイページへのアクセスが失敗する' do
          visit user_path(user)
          expect(current_path).to eq login_path
          expect(page).to have_content('Login required')
        end
      end
    end
  end

  describe 'ログイン後' do
    before { login_as(user) }

    describe 'ユーザー編集' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの編集が成功する' do
          visit edit_user_path(user)
          fill_in 'Email', with: 'hogehoge@example.com'
          fill_in 'Password', with: 'hogehoge'
          fill_in 'Password confirmation', with: 'hogehoge'
          click_button 'Update'
          expect(current_path).to eq user_path(user)
          expect(page).to have_content('User was successfully updated.')
        end
      end
      context 'メールアドレスが未入力' do
        it 'ユーザーの編集が失敗する' do
          visit edit_user_path(user)
          fill_in 'Email', with: nil
          fill_in 'Password', with: 'hogehoge'
          fill_in 'Password confirmation', with: 'hogehoge'
          click_button 'Update'
          expect(current_path).to eq user_path(user)
          expect(page).to have_content('1 error prohibited this user from being saved')
          expect(page).to have_content("Email can't be blank")
        end
      end
      context '登録済のメールアドレスを使用' do
        it 'ユーザーの編集が失敗する' do
          visit edit_user_path(user)
          other_user = create(:user)
          fill_in 'Email', with: other_user.email
          fill_in 'Password', with: 'hogehoge'
          fill_in 'Password confirmation', with: 'hogehoge'
          click_button 'Update'
          expect(current_path).to eq user_path(user)
          expect(page).to have_content('1 error prohibited this user from being saved')
          expect(page).to have_content('Email has already been taken')
        end
      end
      context '他ユーザーの編集ページにアクセス' do
        it '編集ページへのアクセスが失敗する' do
          other_user = create(:user)
          visit edit_user_path(other_user)
          expect(current_path).to eq user_path(user)
          expect(page).to have_content 'Forbidden access.'
        end
      end
    end

    describe 'マイページ' do
      context 'タスクを作成' do
        it '新規作成したタスクが表示される' do
          create(:task, title: 'Title', user: user, status: 'todo')
          visit user_path(user)
          expect(page).to have_content('You have 1 task.')
          expect(page).to have_content('Title')
          expect(page).to have_content('todo')
          expect(page).to have_link('Show')
          expect(page).to have_link('Edit')
          expect(page).to have_link('Destroy')
        end
      end
    end
  end
end
