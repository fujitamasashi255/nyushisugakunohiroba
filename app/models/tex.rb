# frozen_string_literal: true

# == Schema Information
#
# Table name: texes
#
#  id                 :bigint           not null, primary key
#  code               :text
#  texable_type       :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  pdf_blob_signed_id :string
#  texable_id         :bigint           not null
#
# Indexes
#
#  index_texes_on_texable  (texable_type,texable_id)
#
class Tex < ApplicationRecord
  belongs_to :texable, polymorphic: true
  has_one_attached :pdf
  has_one_attached :log_file

  attribute :code, :text, default: Settings.tex_default_code
end
