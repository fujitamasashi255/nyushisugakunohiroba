import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"

require("@nathanvda/cocoon")

import { Dropdown } from "bootstrap/dist/js/bootstrap.esm.min.js";
import "src/admin/QuestionsNewEdit"
import "src/TexCompile"
import "src/questions/Index"

Rails.start()
ActiveStorage.start()

import 'src/pagy.js.erb'
