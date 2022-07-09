# frozen_string_literal: true

class CreateTexes < ActiveRecord::Migration[6.1]
  def change
    create_table :texes, id: :uuid do |t|
      t.references :texable, type: :uuid, polymorphic: true, null: false
      t.text :code
      t.string :compile_result_url, null: false, default: ""

      t.timestamps
    end
  end
end
