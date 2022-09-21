# frozen_string_literal: true

module Sort
  class SortBase
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :sort_type, :string

    def sort(sortable)
      sort_type_block.call(sortable)
    end

    private

    def sort_type_block
      "#{self.class}::#{sort_type.upcase}".constantize
    end
  end
end
