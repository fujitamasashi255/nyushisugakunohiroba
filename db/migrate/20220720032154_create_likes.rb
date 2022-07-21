# frozen_string_literal: true

class CreateLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :likes, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :answer, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
    add_index :likes, [:user_id, :answer_id], unique: true
  end
end
