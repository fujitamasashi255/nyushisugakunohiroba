# frozen_string_literal: true

desc "tmp/rails-latexのファイルで作成から5分たったものを削除する"
task clean_rails_latex_dir: :environment do
  require "fileutils"
  path = Rails.root.join("tmp/rails-latex").to_s
  Dir.children(path).each do |file|
    abs_file = File.join(path, file)
    # 作成から5分以上経ったファイル、ディレクトリを削除
    next unless File.birthtime(abs_file) < Time.current.ago(300)

    if File.file?(abs_file)
      File.delete(abs_file)
    else
      FileUtils.rm_r(abs_file)
    end
  end
end

task test_scheduler: :environment do
  puts "scheduler test"
  puts "it works."
end
