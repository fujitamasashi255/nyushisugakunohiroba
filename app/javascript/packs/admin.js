import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"

require("jquery")
require("@nathanvda/cocoon")

import "@fortawesome/fontawesome-free/js/all.min"
import "bootstrap"
import "src/self_made/AdminQuestionsNewEdit"
import "src/self_made/TexCompile"
import "src/self_made/AdminQuestionsIndex"
import "../stylesheets/admin.scss"

import I18n from 'src/i18n-js/index.js.erb'
I18n.locale = 'ja'
export function t(arg) {
  return I18n.t(arg)
}

Rails.start()
ActiveStorage.start()
