# frozen_string_literal: true

class CreateAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :answers, id: :uuid do |t|
      t.text :ggb_base64
      t.references :user, foreign_key: true, type: :uuid, null: false
      t.references :question, foreign_key: true, type: :uuid, null: false

      t.timestamps
    end
    add_index :answers, [:question_id, :user_id], unique: true
  end
end
