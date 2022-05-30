# frozen_string_literal: true

class SorceryCore < ActiveRecord::Migration[6.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :email, null: false, default: "", index: { unique: true }
      t.string :crypted_password
      t.string :salt
    end
  end
end
