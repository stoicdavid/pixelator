// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
//require("@rails/ujs").start()
//require("turbolinks").start()
//require("@rails/activestorage").start()

import "channels"

//require('@client-side-validations/client-side-validations')
//require("easy-autocomplete")
//require("@zxing/library")
//require("grapheme-splitter")
//import("../src/foundation-datepicker")
//import("../src/promotion_datespan")
//import("../src/sms_counter")
//import("../src/touch_table_highlight")
require("jquery")
require("foundation-sites")
import { Foundation } from 'foundation-sites'
import $ from 'jquery'

document.addEventListener('turbolinks:load', () => $(document).foundation())

Rails.start()
Turbolinks.start()
ActiveStorage.start()
