// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("@rails/activestorage").start()
require("../channels")

// common
import '../stylesheets/application';
import '../javascripts/application';

// +alfa
import '../stylesheets/reset';
import '../stylesheets/login';

import $ from 'jquery';

// special background-image
import bgImg from '~/images/login/19936.jpg';
$(':root')[0].style.setProperty('--url-image-path-login', "url("+ bgImg+")");

//  Materialize
import "materialize-css/dist/js/materialize.min.js";

// initial
$(function(){
  $('.login-container').addClass('show');
});
