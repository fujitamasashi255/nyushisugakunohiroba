import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"

require("jquery")
require("@nathanvda/cocoon")

import "@fortawesome/fontawesome-free/js/all.min"
import "bootstrap"
import "admin-lte"
import "src/self_made/change_depts_checkboxes_by_univ"


import "../stylesheets/admin.scss"

Rails.start()
ActiveStorage.start()
