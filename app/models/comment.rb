# frozen_string_literal: true

# == Schema Information
#
# Table name: comments
#
#  id               :uuid             not null, primary key
#  commentable_type :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  commentable_id   :uuid             not null
#  user_id          :uuid             not null
#
# Indexes
#
#  index_comments_on_commentable  (commentable_type,commentable_id)
#  index_comments_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user
  counter_culture :commentable

  has_rich_text :body
  validates :body, action_text_presence: true, action_text_length: { maximum: 500 }
end
