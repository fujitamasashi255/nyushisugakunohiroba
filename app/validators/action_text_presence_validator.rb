# frozen_string_literal: true

class ActionTextPresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return true unless value.instance_of?(ActionText::RichText)

    # htmlタグ、改行文字を取り除いた文字列を取得
    plain_text_of_value = value.to_plain_text.delete("\n")

    record.errors.add(attribute, options[:message] || "を入力してください") if plain_text_of_value.blank?
  end
end
