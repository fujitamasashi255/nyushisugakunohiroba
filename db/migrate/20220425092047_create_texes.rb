# frozen_string_literal: true

class CreateTexes < ActiveRecord::Migration[6.1]
  def change
    create_table :texes do |t|
      t.references :texable, polymorphic: true, null: false
      t.text :code
      t.string :pdf_blob_signed_id

      t.timestamps
    end
  end
end
