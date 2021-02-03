require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user) { create(:user) }
  let(:task) { create(:task) }

  describe 'ログイン前' do
    describe 'ページ変異確認' do
      context 'タスクの新規登録ページにアクセス' do
        it 'タスク新規登録画面へのアクセスが失敗する' do
          visit new_task_path
          expect(current_path).to eq login_path
          expect(page).to have_content('Login required')
        end
      end

      context 'タスクの編集ページにアクセス' do
        it 'タスク編集画面へのアクセスが失敗する' do
          visit edit_task_path(task)
          expect(current_path).to eq login_path
          expect(page).to have_content('Login required')
        end
      end

      context 'タスクの詳細ページにアクセス' do
        it 'タスクの詳細情報が表示される' do
          visit task_path(task)
          expect(current_path).to eq task_path(task)
          expect(page).to have_content task.title
        end
      end

      context 'タスクの一覧ページにアクセス' do
        it 'すべてのユーザーのタスク情報が表示される' do
          task_list = create_list(:task, 3)
          visit tasks_path
          expect(page).to have_content task_list[0].title
          expect(page).to have_content task_list[1].title
          expect(page).to have_content task_list[2].title
          expect(current_path).to eq tasks_path
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
          fill_in 'Deadline', with: DateTime.new(2021, 2, 28, 10, 30)
          click_button 'Create Task'
          expect(page).to have_content 'Task was successfully created'
          expect(page).to have_content 'Title: foobar'
          expect(page).to have_content 'Content: hogehoge'
          expect(page).to have_content 'Status: todo'
          expect(page).to have_content 'Deadline: 2021/2/28 10:30'
          expect(current_path).to eq '/task/1'
        end
      end
      context 'タイトルが未入力' do
        it 'タスクの新規作成が失敗する' do
          visit new_task_path
          fill_in 'Title', with: nil
          fill_in 'Content', with: 'hogehoge'
          click_button 'Create Task'
          expect(current_path).to eq tasks_path
          expect(page).to have_content '1 error prohibited this task from being saved:'
          expect(page).to have_content "Title can't be blank"
        end
      end
      context '登録済のタイトルを使用' do
        it 'タスクの新規作成が失敗する' do
          visit new_task_path
          other_task = create(:task)
          fill_in 'Title', with: other_task.title
          fill_in 'Content', with: 'hogehoge'
          click_button 'Create Task'
          expect(current_path).to eq tasks_path
          expect(page).to have_content '1 error prohibited this task from being saved'
          expect(page).to have_content 'Title has already been taken'
        end
      end
    end

    describe 'タスク編集' do
      let!(:task) { create(:task, user: user) }
      let(:other_task) { create(:task, user: user) }
      before { visit edit_task_path(task) }

      context 'フォームの入力値が正常' do
        it 'タスクの編集が成功する' do
          fill_in 'Title', with: 'updated_title'
          select :done, from: 'Status'
          click_button 'Update Task'
          expect(current_path).to eq task_path(task)
          expect(page).to have_content 'Task was successfully updated.'
          expect(page).to have_content 'Title: updated_title'
          expect(page).to have_content 'Status: done'
        end
      end
      context 'タイトルが未入力' do
        it 'タスクの編集が失敗する' do
          fill_in 'Title', with: nil
          select :todo, from: 'Status'
          click_button 'Update Task'
          expect(current_path).to eq task_path(task)
          expect(page).to have_content '1 error prohibited this task from being saved'
          expect(page).to have_content "Title can't be blank"
        end
      end
      context '登録済のタイトルを使用' do
        it 'タスクの編集が失敗する' do
          fill_in 'Title', with: other_task.title
          select :todo, from: 'Status'
          click_button 'Update Task'
          expect(current_path).to eq task_path(task)
          expect(page).to have_content '1 error prohibited this task from being saved'
          expect(page).to have_content 'Title has already been taken'
        end
      end
    end

    describe 'タスク削除' do
      let!(:task) { create(:task, user: user)}

      it 'タスクの削除が成功する' do
        visit tasks_path
        click_link 'Destroy'
        expect(page.accept_confirm).to eq 'Are you sure?'
        expect(current_path).to eq tasks_path
        expect(page).to have_content 'Task was successfully destroyed'
        expect(page).not_to have_content task.title
      end
    end
  end
end
