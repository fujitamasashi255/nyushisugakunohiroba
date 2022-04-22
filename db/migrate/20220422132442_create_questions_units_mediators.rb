# frozen_string_literal: true

class CreateQuestionsUnitsMediators < ActiveRecord::Migration[6.1]
  def change
    create_table :questions_units_mediators do |t|
      t.references :question, null: false, foreign_key: true
      t.bigint :unit_id, null: false, index: true
      t.timestamps
    end
  end
end
