# frozen_string_literal: true

class CreateTexes < ActiveRecord::Migration[6.1]
  def change
    create_table :texes, id: :uuid do |t|
      t.references :texable, type: :uuid, polymorphic: true, null: false
      t.text :code
      t.string :pdf_blob_signed_id

      t.timestamps
    end
  end
end
