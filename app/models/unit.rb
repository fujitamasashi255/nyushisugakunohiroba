# frozen_string_literal: true

class Unit < ActiveYaml::Base
  include ActiveHash::Associations

  set_root_path Rails.root.join("config/masters")
  set_filename "unit"

  # has_many :questions
end
