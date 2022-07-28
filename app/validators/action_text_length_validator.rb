# frozen_string_literal: true

class ActionTextLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return true unless value.instance_of?(ActionText::RichText)

    # htmlタグ、改行文字を取り除いた文字数を取得
    value_length = value.to_plain_text.delete("\n").length

    record.errors.add(attribute, options[:message] || "は#{options[:maximum]}文字以下で入力してください") unless options[:maximum].nil? || value_length <= options[:maximum]

    record.errors.add(attribute, options[:message] || "は#{options[:minimum]}文字以上で入力してください") unless options[:minimum].nil? || value_length >= options[:minimum]
  end
end
