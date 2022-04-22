# frozen_string_literal: true

class CreateQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :questions do |t|
      t.integer :set_year, null: false
      t.integer :number, null: false

      t.timestamps
    end
  end
end
