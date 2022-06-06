# frozen_string_literal: true

class AddRememberMeTokenToUsers < ActiveRecord::Migration[6.1]
  def self.up
    change_table :users, bulk: true do |t|
      t.string :remember_me_token, default: nil, index: true
      t.datetime :remember_me_token_expires_at, default: nil
    end
  end

  def self.down
    remove_index :users, :remember_me_token

    remove_column :users, :remember_me_token_expires_at
    remove_column :users, :remember_me_token
  end
end
