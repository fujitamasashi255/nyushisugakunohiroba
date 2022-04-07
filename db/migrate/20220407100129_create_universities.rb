# frozen_string_literal: true

class CreateUniversities < ActiveRecord::Migration[6.1]
  def change
    create_table :universities do |t|
      t.string :name, null: false, unique: true

      t.timestamps
    end
  end
end
