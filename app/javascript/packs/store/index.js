import Vue from 'vue/dist/vue.esm.js'
import Vuex from 'vuex'
// import router from '../router/router.js'
import axios from 'axios'

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    currentUser: {
      id: 0,
      email: null,
      name: null
    },
    workspaces: [],
    selectedWsId: 0,
    selectedWsRole: 2,
    projects: [],
    selectedPjId: 0,
    isPC: false
  },
  mutations: {
    setCurrentUserInfo (state, payload) {
      state.currentUser.id = payload.user.id
      state.currentUser.email = payload.user.email
      state.currentUser.name = payload.user.name
    },
    setWorkspaces (state, payload) {
      state.workspaces = payload.workspaces
    },
    setSelectedWsId (state, id) {
      state.selectedWsId = id
    },
    setSelectedPjId (state, id) {
      state.selectedPjId = id
    },
    setSelectedWsRole (state, role) {
      state.selectedWsRole = role
    },
    setIsPC (state, bool) {
      state.isPC = bool
    },
    setProjects (state, payload) {
      state.projects = payload.projects
    }
  },
  getters: {
    getCurrentUser: state => {
      return state.currentUser
    },
    getWorkspaces: state => {
      return state.workspaces
    },
    getSelectedWsId: state => {
      return state.selectedWsId
    },
    getSelectedPjId: state => {
      return state.selectedPjId
    },
    getSelectedWsRole: state => {
      return state.selectedWsRole
    },
    getIsPC: state => {
      return state.isPC
    },
    getProjects: state => {
      return state.projects
    }
  },
  actions: {
    async fetchCurrentUser ({ commit }, payload) {
      await axios.get('/api/users/' + payload.userId).then((res) => {
        commit('setCurrentUserInfo', res.data)
      }).catch((error) => {
        console.log(error);
      });
    },
    async fetchWorkspaces ({ commit }, payload) {
      await axios.get('/api/workspaces/').then((res) => {
        commit('setWorkspaces', res.data)
      }, (error) => {
        console.log(error);
      })
    },
    async fetchProjects ({ commit, state }, payload) {
      if (state.selectedWsId) {
        if (state.selectedWsRole > 0) {
          await axios.get('/api/workspaces/' + state.selectedWsId + '/projects/').then((res) => {
            commit('setProjects', res.data)
          }, (error) => {
            console.log(error);
          });
        } else {
          await axios.get('/api/workspaces/' + state.selectedWsId + '/projects/index_manager').then((res) => {
            commit('setProjects', res.data)
          }, (error) => {
            console.log(error);
          });
        }
      } else {
        await axios.get('/api/projects/').then((res) => {
          commit('setProjects', res.data)
        }, (error) => {
          console.log(error);
        });
      }

    },
    async createBoardMember ({ commit, state, actions}, payload ) {
      await axios.put('/api/boards/' + payload.boardId + '/update_members/', payload.params)
      .then((res) => {
        this.modalClose()
        this.$emit('update-board-member', this.boardId)
      }, (error) => {
        console.log(error);
      });
    }
  },
})