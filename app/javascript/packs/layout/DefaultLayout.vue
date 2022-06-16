<template>
  <div>
    <Navbar
      @toggle-sidemenu="toggleSideMenu"
      :rst-global-menu-btn-flg="rstGlobalMenuBtnFlg"
      @reload-workspace="reloadWorkspace"
      @open-form-workspace-edit="openFormWorkspaceEdit"
    ></Navbar>
    <div id="body">
      <Sidebar
        ref="sidebar"
        @open-form-project-edit="openFormProjectEdit"
        @open-form-board-edit="openFormBoardEdit"
        :trigger-menu-sp="isOpenSideMenuSp"
        @touch-link-sp="resetGrobalMenuBtn"
        @reload-workspace="reloadWorkspace"
        @open-form-workspace-edit="openFormWorkspaceEdit"
      ></Sidebar>
      <main>
        <div class="container">
          <router-view
            ref="page"
            @open-form-project-edit="openFormProjectEdit"
            @open-form-board-edit="openFormBoardEdit"
            @reload-workspace="reloadWorkspace"
            @update-workspace="updateWorkspace"
            @update-project="updateProject"
            @open-confirm-project-delete="openConfirmProjectDelete"
            @open-confirm-board-delete="openConfirmBoardDelete"
            @flash-on="flashOn"
            @update-board="updateBoard"
            @open-confirm-workspace-delete="openConfirmWorkspaceDelete"
            @open-form-state-edit="openFormStateEdit"
            @open-confirm-state-delete="openConfirmStateDelete"
            :reload-states-flg="reloadStatesFlg"
            @off-trigger-flg="offTriggerFlg"
            @open-confirm-task-delete="openConfirmTaskDelete"
          ></router-view>
        </div>
      </main>

      <ModalGroup
        :type="modalType"
        :is-show="modalShowFlg"
        :target-id="modalTargetId"
        @close-modal="toggleModal"
        @update-workspace="updateWorkspace"
        @update-project="updateProject"
        @update-board="updateBoard"
        @update-state="updateState"
      />

      <FlashMessage
        :is-show="showFlash"
        :message="flashMessage"
        :type="flashType"
        @flash-off="flashOff"
      />

    </div>
  </div>
</template>

<script>
import Navbar from '@/components/common/Navbar'
import Sidebar from '@/components/common/Sidebar'
import FlashMessage from '@/components/flash/FlashMessage'
import ModalGroup from '@/components/Group/ModalGroup.vue'
import { mapGetters } from 'vuex'

export default {
  name: 'default',
  props: {
    currentUserId: {
      type: Number,
      require: false
    }
  },
  data: function () {
    return {
      modalType: null,
      modalShowFlg: false,
      modalTargetId: 0,
      showFlash: false,
      flashMessage: '',
      flashType: '',
      isOpenSideMenuSp: false,
      rstGlobalMenuBtnFlg: false,
      initProjectsLoadedFlg: false,
      ws_owner_flg: false,
      reloadStatesFlg: false,
    }
  },
  components: {
    Navbar,
    Sidebar,
    FlashMessage,
    ModalGroup
  },
  created: function() {},
  mounted: function () {},
  computed: {
    ...mapGetters({
      currentUser: 'getCurrentUser',
      workspaces: 'getWorkspaces',
      selectedWsId: 'getSelectedWsId',
      selectedPjId: 'getSelectedPjId',
      selectedWsRole: 'getSelectedWsRole',
      projects: 'getProjects'
    }),
  },
  methods: {
    reloadWorkspace: function(target_ws_id) {
      // const target_ws_id = data.value
      if (target_ws_id) {
        const selected_ws = this.workspaces.filter ( (ws) => {
          return  ws.id ==  target_ws_id
        })
        if (selected_ws.length) {
          this.$store.commit('setSelectedWsRole', selected_ws[0].role)
        } else {
          this.$store.commit('setSelectedWsRole', 2)
        }
      } else {
        this.$store.commit('setSelectedWsRole', 2)
      }
      this.$store.commit('setSelectedPjId', 0)
      this.fetchProjects()
    },
    fetchProjects: async function () {
      this.$store.dispatch('fetchProjects')
      this.initProjectsLoadedFlg = true
    },
    openFormWorkspaceEdit: function() {
      this.toggleModal(true, {type: 'new_ws', target_id: 0})
    },
    openFormProjectEdit: function(project_id) {
      this.toggleModal(true, {type: 'edit_pj', target_id: project_id})
    },
    openFormBoardEdit: function(projectid, boardid = 0) {
      if (boardid) {
        this.toggleModal(true, {type: 'edit_bd', target_id: boardid})
      } else if (projectid) {
        this.toggleModal(true, {type: 'new_bd', target_id: projectid})
      }
    },
    updateWorkspace: async function() {
      const _this = this
      await Promise.all([
        _this.$store.dispatch('fetchWorkspaces')
      ])
      const selected_ws = this.workspaces.filter ( (ws) => {
        return  ws.id ==  _this.selectedWsId
      })
      if (selected_ws.length) {
        this.$store.commit('setSelectedWsRole', selected_ws[0].role)
      } else {
        this.$store.commit('setSelectedWsRole', 2)
      }
      this.fetchProjects()
    },
    updateProject: function() {
      this.fetchProjects()
    },
    openConfirmWorkspaceDelete: function(workspace_id) {
      this.toggleModal(true, {type: 'delete_ws', target_id: workspace_id})
    },
    openConfirmProjectDelete: function(project_id) {
      this.toggleModal(true, {type: 'delete_pj', target_id: project_id})
    },
    toggleModal(enable, data) {
      if (enable) {
        this.modalShowFlg = enable
        this.modalType = data.type
        this.modalTargetId = data.target_id
      } else {
        this.modalShowFlg = false
        this.modalType = null
        this.modalTargetId = 0
      }
    },
    updateBoard: function() {
      this.fetchProjects()
    },
    openConfirmBoardDelete: function(board_id) {
      this.toggleModal(true, {type: 'delete_bd', target_id: board_id})
    },
    openFormStateEdit: function(board_id = 0, state_id = 0) {
      if (state_id) {
        this.toggleModal(true, {type: 'edit_state', target_id: state_id})
      } else if (board_id) {
        this.toggleModal(true, {type: 'new_state', target_id: board_id})
      }
    },
    updateState: function() {
      this.reloadStatesFlg = true
    },
    openConfirmStateDelete: function(state_id) {
      this.toggleModal(true, {type: 'delete_state', target_id: state_id})
    },
    offTriggerFlg: function() {
      this.reloadStatesFlg = false
    },
    openConfirmTaskDelete: function(task_id) {
      this.toggleModal(true, {type: 'delete_task', target_id: task_id})
    },
    flashOn: function(msg, type) {
      this.showFlash = true
      this.flashMessage = msg
      this.flashType = type
    },
    flashOff: function() {
      this.showFlash = false
      this.flashMessage = ''
    },
    toggleSideMenu: function(val) {
      this.isOpenSideMenuSp = val
      this.rstGlobalMenuBtnFlg = false
    },
    resetGrobalMenuBtn: function() {
      this.rstGlobalMenuBtnFlg = true
    }
  },
}
</script>

<style lang="scss">
@import url('https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,400;0,500;0,700;1,300;1,400;1,500;1,700&display=swap');
* {
  font-family: 'Roboto', sans-serif;
}
p {
  text-align: center;
}
.page-container {
  width: 95%;
  margin: 10px auto;
  .page-head {
    position: relative;
    padding-bottom: 20px;
    margin-top: 10px;
    @media screen and (min-width: 768px) {
      padding-bottom: 20px;
    }
    .sw-cnt {
      position: absolute;
      top: 10px;
      right: 0;
      width: 20px;
      height: 20px;
      text-align: center;
      cursor: pointer;
      &:hover {
        opacity: 0.7;
      }
    }
    .cnt-list {
      transition: all 300ms 0s ease;
      display: block;
      position: absolute;
      top: 10px;
      right: 30px;
      padding: 10px;
      li {
        padding: 5px;
        &:hover {
          opacity: 0.7;
        }
      }
    }
  }
  h1 {
    font-size: 22px;
    font-weight: 500;
    margin-bottom: 20px;
    display: inline-block;
    @media screen and (min-width: 768px) {
      font-size: 28px;
    }
  }
  .page-title-edit input {
    height: 30px;
    font-size: 22px;
    border: none;
    border-radius: 4px;
    @media screen and (min-width: 768px) {
      font-size: 28px;
    }
  }
  .page-desc {
    font-size: 16px;
    text-align:left;
    white-space: pre-wrap;
    @media screen and (min-width: 768px) {
      font-size: 18px;
    }
    &-edit textarea {
      font-size: 16px;
      text-align:left;
      border: none;
      border-radius: 4px;
      height: 3rem;
      width: 100%;
      @media screen and (min-width: 768px) {
        font-size: 18px;
      }
    }
  }
  .subsection{
    h2 {
      font-size: 18px;
      margin: 10px 0px;
      @media screen and (min-width: s768px) {
        font-size: 22px;
        margin: 10px 0px 20px;
      }
    }
  }
}
#body {
  height: calc(100vh - 50px);
  margin-top: 50px;
  display: flex;
}
main {
  width: 100%;
  background-color: #f3f3f3;
  overflow: auto;
}
.modal {
  display: block;
  height: 100vh;
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  z-index: 1000;
}
.modal__bg {
    background: rgba(0,0,0,.8);
    height: 100vh;
    position: absolute;
    width: 100%;
}
.modal__content {
  background: #fff;
  left: 50%;
  padding: 10px;
  position: absolute;
  top: 50%;
  transform: translate(-50%,-50%);
  width: 90%;
  max-width: 800px;
  margin: 0 auto;
  text-align: center;
  .js-modal-close {
    position: absolute;
    top: 15px;
    right: 10px;
    cursor: pointer;
    span {
      display: block;
      width: 20px;
      height: 20px;
      position: relative;
      &::before, &::after {
        content: "";
        display: block;
        width: 100%;
        height: 2px;
        background: #333;
        transform: rotate(45deg);
        transform-origin: 0 50%;
        position: absolute;
        top: calc(14% - 5px);
        left: 14%;
      }
      &::after {
        transform: rotate(-45deg);
        transform-origin: 100% 50%;
        left: auto;
        right: 14%;
      }
    }
  }
  .modal_title {
    display: inline-block;
    font-size: 18px;
    margin: 0 auto 10px;
    line-height: 2;
    span {
      border-bottom: 1px solid #6782ae;
      padding-bottom: .3em;
    }
  }
  .modal_txt {
      margin-bottom: 20px;
  }
  .modal_message {
    margin-bottom: 20px;
    font-size: 14px;
    line-height: 1.6;
  }
  input, textarea {
    padding: 10px 10px;
    width: 100%;
    max-width: 300px;
    border: none;
    background: #f1f1f1;
  }
  input:focus, textarea:focus {
    background: rgba(255,255,255,0.3)
  }
}

.modal-enter-active {
  transition: all 0.3s ease-out;
}
.modal-leave-active {
  transition: all 0.3s cubic-bezier(1, 0.5, 0.8, 1);
}
.modal-enter,
.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}
.js-modal {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}
.logo-top {
  width: 160px;
}
.modal__content {
  .form-ctl {
    input,
    textarea {
      width: 100%;
      max-width: initial;
    }
  }
}


.form-ctl {
  width: 100%;
  margin-bottom: 20px;
  text-align: left;
  label {
    padding: 10px 0;
    display: inline-block;
  }
  input,
  textarea {
    width: 100%;
  }
  select {
    width: 50%;
    max-width: 600px;
  }
  .form-ctl__body--row {
    display: flex;
    align-items: center;
    span {
      display: flex;
      align-items: center;
    }
    input[type="date"] {
      width: 160px;
    }
  }
  &__text {
    white-space: pre-wrap;
    word-wrap: break-word;
    text-align: left;
  }
  &__body {
    .form-ctl__text {
      padding-left: 20px;
    }
  }
}
</style>
