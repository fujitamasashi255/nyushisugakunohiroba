# frozen_string_literal: true

# == Schema Information
#
# Table name: texes
#
#  id           :bigint           not null, primary key
#  tex_code     :text             not null
#  texable_type :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  texable_id   :bigint           not null
#
# Indexes
#
#  index_texes_on_texable  (texable_type,texable_id)
#
class Tex < ApplicationRecord
  validates :tex_code, presence: true

  belongs_to :texable, polymorphic: true
  has_one_attached :pdf
  has_one_attached :log_file
end
