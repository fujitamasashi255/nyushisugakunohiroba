# frozen_string_literal: true

require "csv"

csv_national_or_public = CSV.read("db/fixtures/universities-national-or-public.csv")
csv_national_or_public.each do |university|
  University.seed(:name) do |s|
    s.name = university[0]
    s.category = :national_or_public
    s.prefecture = Prefecture.find_by(name: university[1])
  end
end

csv_private = CSV.read("db/fixtures/universities-private.csv")
csv_private.each do |university|
  University.seed(:name) do |s|
    s.name = university[0]
    s.category = :private
    s.prefecture = Prefecture.find_by(name: university[1])
  end
end
