# frozen_string_literal: true

class AddPrefectureIdToUniversities < ActiveRecord::Migration[6.1]
  def change
    add_column :universities, :prefecture_id, :bigint, index: true
  end
end
