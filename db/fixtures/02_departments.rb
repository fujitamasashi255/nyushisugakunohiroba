# frozen_string_literal: true

require "csv"

# csvデータは [大学名, 都道府県, 学部名] の形式

csv_national_or_public = CSV.read("db/fixtures/national-or-public-univs-depts.csv")
csv_national_or_public.each do |university|
  university[2].split(",").each do |dept_name|
    Department.seed(:university_id, :name) do |s|
      s.university_id = University.find_by(name: university[0]).id
      s.name = dept_name
    end
  end
end

csv_private = CSV.read("db/fixtures/private-univs-depts.csv")
csv_private.each do |university|
  university[2].split(",").each do |dept_name|
    Department.seed(:university_id, :name) do |s|
      s.university_id = University.find_by(name: university[0]).id
      s.name = dept_name
    end
  end
end
