# frozen_string_literal: true

# == Schema Information
#
# Table name: taggings
#
#  id            :bigint           not null, primary key
#  context       :string(128)
#  taggable_type :string
#  tagger_type   :string
#  tenant        :string(128)
#  created_at    :datetime
#  tag_id        :integer
#  taggable_id   :uuid
#  tagger_id     :uuid
#
# Indexes
#
#  index_taggings_on_context                        (context)
#  index_taggings_on_tag_id                         (tag_id)
#  index_taggings_on_taggable_id                    (taggable_id)
#  index_taggings_on_taggable_type                  (taggable_type)
#  index_taggings_on_taggable_type_and_taggable_id  (taggable_type,taggable_id)
#  index_taggings_on_tagger_id                      (tagger_id)
#  index_taggings_on_tagger_id_and_tagger_type      (tagger_id,tagger_type)
#  index_taggings_on_tagger_type_and_tagger_id      (tagger_type,tagger_id)
#  index_taggings_on_tenant                         (tenant)
#  taggings_idx                                     (tag_id,taggable_id,taggable_type,context,tagger_id,tagger_type) UNIQUE
#  taggings_idy                                     (taggable_id,taggable_type,tagger_id,context)
#  taggings_taggable_context_idx                    (taggable_id,taggable_type,context)
#
# Foreign Keys
#
#  fk_rails_...  (tag_id => tags.id)
#
class Tagging < ApplicationRecord
  belongs_to :tag
end
