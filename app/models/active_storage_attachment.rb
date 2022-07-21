# frozen_string_literal: true

# == Schema Information
#
# Table name: active_storage_attachments
#
#  id          :uuid             not null, primary key
#  name        :string           not null
#  position    :integer
#  record_type :string           not null
#  created_at  :datetime         not null
#  blob_id     :uuid             not null
#  record_id   :uuid             not null
#
# Indexes
#
#  index_active_storage_attachments_on_blob_id  (blob_id)
#  index_active_storage_attachments_uniqueness  (record_type,record_id,name,blob_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (blob_id => active_storage_blobs.id)
#
class ActiveStorageAttachment < ApplicationRecord
end
