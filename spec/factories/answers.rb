# frozen_string_literal: true

# == Schema Information
#
# Table name: answers
#
#  id          :uuid             not null, primary key
#  ggb_base64  :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  question_id :uuid             not null
#  user_id     :uuid             not null
#
# Indexes
#
#  index_answers_on_question_id              (question_id)
#  index_answers_on_question_id_and_user_id  (question_id,user_id) UNIQUE
#  index_answers_on_user_id                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :answer do
    point { "" }
    files { nil }
    user
    question

    transient do
      tag_names { nil }
    end

    before(:create) do |answer, evaluator|
      answer.tag_list.add(evaluator.tag_names)
      tex = build(:tex, texable: answer)
      answer.tex = tex
    end

    trait :attached_text_file do
      files { [Rack::Test::UploadedFile.new(Rails.root.join("spec/files/test.txt"), "text/plain")] }
    end

    trait :attached_jpg_file do
      files { [Rack::Test::UploadedFile.new(Rails.root.join("spec/files/test.jpg"), "image/jpg")] }
    end

    trait :attached_png_file do
      files { [Rack::Test::UploadedFile.new(Rails.root.join("spec/files/test.png"), "img/png")] }
    end

    trait :attached_pdf_file do
      files { [Rack::Test::UploadedFile.new(Rails.root.join("spec/files/test.pdf"), "application/pdf")] }
    end

    trait :attached_4_files do
      files do
        [\
          Rack::Test::UploadedFile.new(Rails.root.join("spec/files/test.pdf"), "application/pdf"), \
          Rack::Test::UploadedFile.new(Rails.root.join("spec/files/test.png"), "image/png"), \
          Rack::Test::UploadedFile.new(Rails.root.join("spec/files/test.jpg"), "image/jpg"), \
          Rack::Test::UploadedFile.new(Rails.root.join("spec/files/test.pdf"), "application/pdf")\
        ]
      end
    end

    trait :attached_over_3MB_file do
      files { [Rack::Test::UploadedFile.new(Rails.root.join("spec/files/over_3MB_image.png"), "image/png")] }
    end
  end
end
