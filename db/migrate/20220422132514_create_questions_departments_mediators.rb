# frozen_string_literal: true

class CreateQuestionsDepartmentsMediators < ActiveRecord::Migration[6.1]
  def change
    create_table :questions_departments_mediators do |t|
      t.references :question, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true
      t.integer :question_number, null: false

      t.timestamps
    end
    add_index :questions_departments_mediators, [:question_id, :department_id], unique: true, name: "index_questions_depts_mediators_on_question_id_and_dept_id"
  end
end
