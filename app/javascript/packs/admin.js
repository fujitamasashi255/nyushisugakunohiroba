import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"

require("jquery")
require("@nathanvda/cocoon")

import "bootstrap"
import "src/admin/QuestionsNewEdit"
import "src/TexCompile"
import "src/questions/Index"

Rails.start()
ActiveStorage.start()

import 'src/pagy.js.erb'
