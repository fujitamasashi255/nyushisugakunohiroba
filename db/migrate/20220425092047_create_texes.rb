# frozen_string_literal: true

class CreateTexes < ActiveRecord::Migration[6.1]
  def change
    create_table :texes do |t|
      t.references :texable, polymorphic: true, null: false
      t.text :tex_code, null: false

      t.timestamps
    end
  end
end
