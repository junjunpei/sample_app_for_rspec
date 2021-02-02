require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user) { create(:user) }
  let(:task) { create(:task, user: user) }
  let(:same_title_task) { create(:task) }

  describe 'ログイン前' do
    describe 'タスク新規登録画面' do
      context 'ログインしていない状態' do
        it 'タスク新規登録画面へのアクセスが失敗する' do
          visit new_task_path
          expect(current_path).to eq login_path
          expect(page).to have_content 'Login required'
        end
      end
    end

    describe 'タスク編集画面' do
      describe 'タスク編集画面' do
        context 'ログインしていない状態' do
          it 'タスク編集画面へのアクセスが失敗する' do
            visit edit_task_path(task)
            expect(current_path).to eq login_path
            expect(page).to have_content 'Login required'
          end
        end
      end
    end
  end

  describe 'ログイン後' do
    before { login_as(user) }
    describe 'タスク新規登録' do
      context 'フォームの入力値が正常' do
        it 'タスクの新規作成が成功する' do
          visit new_task_path
          fill_in 'Title', with: 'foobar'
          fill_in 'Content', with: 'hogehoge'
          select 'todo', from: 'Status'
          fill_in 'Deadline', with: 1.day.from_now
          click_button 'Create Task'
          expect(page).to have_content 'Task was successfully created'
        end
      end
      context 'タイトルが未入力' do
        it 'タスクの新規作成が失敗する' do
          visit new_task_path
          fill_in 'Title', with: nil
          fill_in 'Content', with: 'hogehoge'
          select 'todo', from: 'Status'
          fill_in 'Deadline', with: 1.day.from_now
          click_button 'Create Task'
          expect(current_path).to eq tasks_path
          expect(page).to have_content "Title can't be blank"
        end
      end
      context '登録済のタイトルを使用' do
        it 'タスクの新規作成が失敗する' do
          visit new_task_path
          fill_in 'Title', with: same_title_task.title
          fill_in 'Content', with: 'hogehoge'
          select 'todo', from: 'Status'
          fill_in 'Deadline', with: 1.day.from_now
          click_button 'Create Task'
          expect(current_path).to eq tasks_path
          expect(page).to have_content 'Title has already been taken'
        end
      end
    end

    describe 'タスク編集' do
      context 'フォームの入力値が正常' do
        it 'タスクの編集が成功する' do
          visit edit_task_path(task)
          fill_in 'Title', with: 'New Title'
          click_button 'Update Task'
          expect(current_path).to eq task_path(task)
          expect(page).to have_content 'Task was successfully updated.'
        end
      end
      context 'タイトルが未入力' do
        it 'タスクの編集が失敗する' do
          visit edit_task_path(task)
          fill_in 'Title', with: nil
          click_button 'Update Task'
          expect(current_path).to eq task_path(task)
          expect(page).to have_content "Title can't be blank"
        end
      end
      context '登録済のタイトルを使用' do
        it 'タスクの編集が失敗する' do
          visit edit_task_path(task)
          fill_in 'Title', with: same_title_task.title
          click_button 'Update Task'
          expect(current_path).to eq task_path(task)
          expect(page).to have_content 'Title has already been taken'
        end
      end
    end

    describe 'タスク削除' do
      let!(:task) { create(:task, user: user)}
      it 'タスクの削除が成功する' do
        visit tasks_path
        click_link 'Destroy'
        page.accept_confirm 'Are you sure?'
        expect(current_path).to eq tasks_path
        expect(page).to have_content 'Task was successfully destroyed'
      end
    end
  end
end
