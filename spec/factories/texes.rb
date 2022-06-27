# frozen_string_literal: true

# == Schema Information
#
# Table name: texes
#
#  id                 :uuid             not null, primary key
#  code               :text
#  texable_type       :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  pdf_blob_signed_id :string
#  texable_id         :uuid             not null
#
# Indexes
#
#  index_texes_on_texable  (texable_type,texable_id)
#
FactoryBot.define do
  factory :tex do
    code { "" }
    pdf_blob_signed_id { "" }
    pdf { Rack::Test::UploadedFile.new(Rails.root.join("spec/files/test.pdf"), "application/pdf") }

    transient do
      texable { nil }
    end

    texable_id { texable&.id }
    texable_type { texable&.class&.name }

    trait :with_attachment do
      pdf { Rack::Test::UploadedFile.new(Rails.root.join("spec/files/test.pdf"), "application/pdf") }
    end
  end
end
