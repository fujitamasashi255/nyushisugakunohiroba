# frozen_string_literal: true

class AddCategoryToUniversities < ActiveRecord::Migration[6.1]
  def change
    add_column :universities, :category, :integer, default: 0, null: false
  end
end
