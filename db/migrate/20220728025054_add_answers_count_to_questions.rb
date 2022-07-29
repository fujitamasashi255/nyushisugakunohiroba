# frozen_string_literal: true

class AddAnswersCountToQuestions < ActiveRecord::Migration[6.1]
  def self.up
    add_column :questions, :answers_count, :integer, null: false, default: 0
  end

  def self.down
    remove_column :questions, :answers_count
  end
end
