// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "../stylesheets/application.scss"
import "bootstrap"
import "src/self_made/QuestionsIndex"
import "src/self_made/FlashMessages"
import "src/self_made/Users"
import "src/self_made/TexCompile"

import I18n from 'src/i18n-js/index.js.erb'
I18n.locale = 'ja'
export function t(arg) {
  return I18n.t(arg)
}

Rails.start()
ActiveStorage.start()
