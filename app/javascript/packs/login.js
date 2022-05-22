// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("@rails/activestorage").start()
// require("../channels")

// common
import '../stylesheets/application';
// import '../javascripts/application';

// +alfa
import '../stylesheets/reset';
import '../stylesheets/login';

import $ from 'jquery';

const images = require.context("../images", true);
const imagePath = name => images(name, true);

//  Materialize
import "materialize-css/dist/js/materialize.min.js";

// initial
$(function(){
  $('.login-container').addClass('show');
});
