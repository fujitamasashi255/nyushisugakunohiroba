# frozen_string_literal: true

class CreateQuestionsDepartmentsMediators < ActiveRecord::Migration[6.1]
  def change
    create_table :questions_departments_mediators do |t|
      t.references :question, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true

      t.timestamps
    end
  end
end
