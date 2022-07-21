# frozen_string_literal: true

# == Schema Information
#
# Table name: likes
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  answer_id  :uuid             not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_likes_on_answer_id              (answer_id)
#  index_likes_on_user_id                (user_id)
#  index_likes_on_user_id_and_answer_id  (user_id,answer_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (answer_id => answers.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :like do
    answer
    user
  end
end
