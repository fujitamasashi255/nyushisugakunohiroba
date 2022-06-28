# frozen_string_literal: true

require "csv"

csv_national_or_public = CSV.read("db/fixtures/departments-national-or-public.csv")
csv_national_or_public.each do |department|
  department[1].split(",").each do |dept_name|
    Department.seed(:university_id, :name) do |s|
      s.university_id = University.find_by(name: department[0]).id
      s.name = dept_name
    end
  end
end

csv_private = CSV.read("db/fixtures/departments-private.csv")
csv_private.each do |department|
  department[1].split(",").each do |dept_name|
    Department.seed(:university_id, :name) do |s|
      s.university_id = University.find_by(name: department[0]).id
      s.name = dept_name
    end
  end
end
