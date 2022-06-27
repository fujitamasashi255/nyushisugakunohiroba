# frozen_string_literal: true

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

    trait :attached_over_1MB_file do
      files { [Rack::Test::UploadedFile.new(Rails.root.join("spec/files/over_1MB_image.png"), "image/png")] }
    end
  end
end
