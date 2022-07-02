// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "bootstrap"
window.bootstrap = require("bootstrap");
import "src/questions/Index"
import "src/FlashMessages"
import "src/Users"
import "src/TexCompile"
import "src/answers/Form"
import "src/answers/Index"
import "src/MathJax"
import "src/answers/CreateEditTags"
import "src/questions/SearchTags"
import "src/answers/SearchTags"
import "src/ActionText"

import I18n from 'src/i18n-js/index.js.erb'
I18n.locale = 'ja'
export function t(arg) {
  return I18n.t(arg)
}

Rails.start()
ActiveStorage.start()

import 'src/pagy.js.erb'
