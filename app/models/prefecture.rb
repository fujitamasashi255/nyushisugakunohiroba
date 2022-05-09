# frozen_string_literal: true

class Prefecture < ActiveYaml::Base
  include ActiveHash::Associations

  set_root_path Rails.root.join("config/masters")
  set_filename "prefecture"

  has_many :universities, dependent: :destroy
end
