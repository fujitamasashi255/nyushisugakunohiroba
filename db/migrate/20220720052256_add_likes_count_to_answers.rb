# frozen_string_literal: true

class AddLikesCountToAnswers < ActiveRecord::Migration[6.1]
  def self.up
    add_column :answers, :likes_count, :integer, null: false, default: 0
  end

  def self.down
    remove_column :answers, :likes_count
  end
end
