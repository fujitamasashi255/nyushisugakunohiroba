import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"

require("jquery")
require("@nathanvda/cocoon")

import "bootstrap"
import "src/self_made/AdminQuestionsNewEdit"
import "src/self_made/TexCompile"
import "src/self_made/QuestionsIndex"
import "../stylesheets/admin.scss"

Rails.start()
ActiveStorage.start()

import 'src/pagy.js.erb'
