# frozen_string_literal: true

module UniversityDecorator
  def confirm
    new_record? ? nil : t("messages.update_confirm")
  end
end
