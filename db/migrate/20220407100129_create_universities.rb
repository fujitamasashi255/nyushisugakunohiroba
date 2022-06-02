# frozen_string_literal: true

class CreateUniversities < ActiveRecord::Migration[6.1]
  def change
    create_table :universities do |t|
      t.string :name, null: false, unique: true
      t.index :name, unique: true

      t.timestamps
    end

    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
  end
end
