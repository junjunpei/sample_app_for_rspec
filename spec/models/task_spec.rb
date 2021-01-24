require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validation' do
    it 'is valid with all attributes' do
      expect(FactoryBot.build(:task)).to be_valid
    end

    it 'is invalid without title' do
      task = FactoryBot.build(:task, title: nil)
      task.valid?
      expect(task.errors[:title]).to include("can't be blank")
    end

    it 'is invalid without status' do
      task = FactoryBot.build(:task, status: nil)
      task.valid?
      expect(task.errors[:status]).to include("can't be blank")
    end

    it 'is invalid with a duplicate title' do
      task = FactoryBot.create(:task)
      task2 = FactoryBot.build(:task, title: task.title)
      task2.valid?
      expect(task2.errors[:title]).to include("has already been taken")
    end

    it 'is valid with another title' do
      task = FactoryBot.create(:task)
      expect(FactoryBot.build(:task)).to be_valid
    end

  end
end
