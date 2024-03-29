# frozen_string_literal: true

# Instance variables
# See https://ddnexus.github.io/pagy/api/pagy#instance-variables
require "pagy/extras/bootstrap"
require "pagy/extras/support"
require "pagy/extras/countless"

Pagy::DEFAULT[:items] = 20
Pagy::DEFAULT[:size]  = [1, 4, 4, 1]

Pagy::I18n.load(locale: "ja", filepath: "config/locales/pagy-ja.yml")
