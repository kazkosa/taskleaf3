/* eslint no-console: 0 */
// Run this example by adding <%= javascript_pack_tag 'hello_vue' %> (and
// <%= stylesheet_pack_tag 'hello_vue' %> if you have styles in your component)
// to the head of your layout file,
// like app/views/layouts/application.html.erb.
// All it does is render <div>Hello Vue</div> at the bottom of the page.

require("@rails/ujs").start()
// require("turbolinks").start()
require("@rails/activestorage").start()
require("../channels")


// Fontawesome
import '@fortawesome/fontawesome-free/js/all';

import '../stylesheets/todo';

// import Vue from 'vue'
import Vue from 'vue/dist/vue.esm.js'
// import Vuex from 'vuex'
import App from '../app.vue'
import Router from './router/router'
import store  from './store'


// import '../javascripts/todo';

// document.addEventListener('DOMContentLoaded', () => {
//   const app = new Vue({
//     render: h => h(App)
//   }).$mount()
//   document.body.appendChild(app.$el)

//   console.log(app)
// })

// Vue.use(Vuex);
Vue.config.productionTip = false

var app = new Vue({
  router: Router,
  el: '#app',
  store,
  components: {
    'app': App,
  },
});


// The above code uses Vue without the compiler, which means you cannot
// use Vue to target elements in your existing html templates. You would
// need to always use single file components.
// To be able to target elements in your existing html/erb templates,
// comment out the above code and uncomment the below
// Add <%= javascript_pack_tag 'hello_vue' %> to your layout
// Then add this markup to your html template:
//
// <div id='hello'>
//   {{message}}
//   <app></app>
// </div>


