# frozen_string_literal: true

class AddPositionToActiveStorageAttachments < ActiveRecord::Migration[6.1]
  def change
    add_column :active_storage_attachments, :position, :integer
  end
end
