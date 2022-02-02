import Vue from 'vue/dist/vue.esm.js'
import VueRouter from 'vue-router'
import Index from '../components/index.vue'
import About from '../components/about.vue'
import Contact from '../components/contact.vue'
import Mystation from '../components/mystation.vue'
import Project from '../components/project.vue'
import Board from '../components/board.vue'

Vue.use(VueRouter)

export default new VueRouter({
  mode: 'history',
  base: '/dashboard',
  routes: [
    { path: '/', component: Mystation },
    { path: '/about', component: About },
    { path: '/contact', component: Contact },
    { path: '/mystation', component: Mystation },
    {
      path: '/projects/:id',
      name: 'project',
      component: Project
    },
    {
      path: '/boards/:id',
      name: 'board',
      component: Board
    },
  ],
})