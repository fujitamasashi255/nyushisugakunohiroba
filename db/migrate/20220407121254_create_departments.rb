# frozen_string_literal: true

class CreateDepartments < ActiveRecord::Migration[6.1]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.references :university, foreign_key: true

      t.timestamps
    end
  end
end
