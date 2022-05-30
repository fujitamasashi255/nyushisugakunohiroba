# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name, null: false
      t.integer :role, null: false

      t.timestamps
    end
  end
end
