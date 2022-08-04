// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "src/ActionText"
import "channels"
import "src/FlashMessages"
import "src/Users"
import "src/MathJax"
import "src/TexCompile"
import "src/questions/Index"
import "src/questions/SearchTags"
import "src/comment"
import "src/answers/FilesCarousel"
import "src/answers/Form"
import "src/answers/Index"
import "src/answers/SearchTags"
import "src/answers/CreateEditTags"
import "src/Loading"


const images = require.context("../images", true);
const imagePath = name => images(name, true);

import I18n from 'src/i18n-js/index.js.erb'
I18n.locale = 'ja'
export function t(arg) {
  return I18n.t(arg)
}

Rails.start()
ActiveStorage.start()

import 'src/pagy.js.erb'
