# frozen_string_literal: true

class QuestionsAnswersSearchFormBase
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :university_ids
  attribute :start_year, :integer
  attribute :end_year, :integer
  attribute :unit_ids
  attribute :tag_names, :string, default: -> { "" }
  attribute :sort_type, :string, default: -> { "year_new" }

  def search
    raise "This #{self.class} cannot respond to:"
  end

  private

  def search_conditions
    {
      university_ids: university_ids_no_blank,
      unit_ids: unit_ids_no_blank,
      start_year:,
      end_year:,
      tag_name_array:
    }
  end

  def sort_conditions
    { sort_type: }
  end

  def university_ids_no_blank
    university_ids&.reject(&:blank?)
  end

  def unit_ids_no_blank
    unit_ids&.reject(&:blank?)
  end

  # tag_names="tag1, tag2"をtag_list=["tag1", "tag2"]へ
  def tag_name_array
    tag_names&.split(",")
  end
end
