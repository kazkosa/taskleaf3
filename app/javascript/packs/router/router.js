import Vue from 'vue/dist/vue.esm.js'
import VueRouter from 'vue-router'
import Index from '../components/index.vue'
import About from '../components/about.vue'
import Contact from '../components/contact.vue'
import Mystation from '../pages/Mystation.vue'
import Workspace from '../pages/Workspace.vue'
import Project from '../pages/Project.vue'
import Board from '../pages/Board.vue'

Vue.use(VueRouter)

// export default new VueRouter({
// export default router
const router = new VueRouter({
  mode: 'history',
  base: '/app',
  routes: [
    { 
      path: '/',
      meta: { layout: 'simple'},
      component: Mystation
    },
    { path: '/about', component: About },
    { path: '/contact', component: Contact },
    { 
      path: '/mystation',
      name: 'mystation',
      meta: { layout: 'simple'},
      component: Mystation 
    },
    
    {
      path: '/ws/',
      name: 'workspace-global',
      component: Workspace,
      
    },
    {
      path: '/ws/:ws_id',
      name: 'workspace',
      component: Workspace,
      children: [
        {
          path: 'members',
          name: 'workspace-member',
          component: Workspace,
        },
        {
          path: 'setting',
          name: 'workspace-setting',
          component: Workspace,
        }
      ]
    },
    {
      path: '/projects/:id',
      name: 'project',
      component: Project,
      children: [
        {
          path: 'members',
          name: 'project-member',
          component: Project,
        },
        {
          path: 'setting',
          name: 'project-setting',
          component: Project,
        }
      ]
    },
    
    {
      path: '/boards/:id',
      name: 'board',
      component: Board,
      children: [
        {
          path: 'members',
          name: 'board-member',
          component: Board
        },
        {
          path: 'setting',
          name: 'board-setting',
          component: Board
        }
      ]
    },
  ],
})
router.beforeEach( (to, from, next) => {
  next()
})
export default router