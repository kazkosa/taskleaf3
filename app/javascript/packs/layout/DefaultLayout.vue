<template>
  <div>
    <Navbar
      :current-user="current_user"
      @toggle-sidemenu="toggleSideMenu"
      :rst-global-menu-btn-flg="rstGlobalMenuBtnFlg"
      :selected-space-id="selected_space_id"
      :workspaces="workspaces"
      :is-pc="isPC"
      @reload-workspace="reloadWorkspace"
      @open-form-workspace-edit="openFormWorkspaceEdit"
    ></Navbar>
    <div id="body">
      <Sidebar
        ref="sidebar"
        :current-user="current_user"

        :selected-space-id="selected_space_id"
        :selected-space-role="selected_space_role"
        :workspaces="workspaces"
        :projects="projects"
        :target-open-projectid="selected_project_id"
        @open-form-project-edit="openFormProjectEdit"
        @open-form-board-edit="openFormBoardEdit"
        :trigger-menu-sp="isOpenSideMenuSp"
        :is-pc="isPC"
        @touch-link-sp="resetGrobalMenuBtn"
        @reload-workspace="reloadWorkspace"
        @open-form-workspace-edit="openFormWorkspaceEdit"
      ></Sidebar>
      <main>
        <div class="container">
          <router-view
            ref="page"
            :current-user="current_user"
            :selected-space-id="selected_space_id"
            :projects="projects"
            :workspaces="workspaces"
            
            @open-form-project-edit="openFormProjectEdit"
            @open-form-board-edit="openFormBoardEdit"
            @get-workspaceid-from-url="getWorkspaceIdFromUrl"
            @reload-workspace="reloadWorkspace"
            @get-projectid-from-url="getProjectIdFromUrl"
            @update-workspace="updateWorkspace"
            @update-project="updateProject"
            @open-confirm-project-delete="openConfirmProjectDelete"
            @open-confirm-board-delete="openConfirmBoardDelete"
            @flash-on="flashOn"
            @keypress.esc="closeModal"

            @update-board="updateBoard"

            @open-confirm-workspace-delete="openConfirmWorkspaceDelete"
          ></router-view>
        </div>
      </main>


      <FormWorkspaceEdit
        :is-show="showFormWorkspaceEdit"
        :selected-space-id="selected_space_id"
        @close-modal="closeModal"
        @create-workspace="createWorkspace"
      ></FormWorkspaceEdit>
      <FormProjectEdit
        :is-show="showFormProjectEdit"
        :selected-space-id="selected_space_id"
        @close-modal="closeModal"
        @add-project="addProject"
        :project-id="editProjectId"
        @update-project="updateProject"
      ></FormProjectEdit>
      <FormBoardEdit
        :is-show="showFormBoardEdit"
        :project-id="targetProjectIdFormBoard"
        :board-id="targetBoardIdFormBoard"
        @close-modal="closeModal"
        @add-board="addBoard"
        @update-board="updateBoard"
      ></FormBoardEdit>
      
      <ModalWorkspaceDelete
        :is-show="showConfirmWorkspaceDelete"
        :workspace-id="deleteWorkspaceId"
        @update-workspace="updateWorkspace"
        @close-modal="closeModal"
      ></ModalWorkspaceDelete>

      <ModalProjectDelete
        :is-show="showConfirmProjectDelete"
        :project-id="deleteProjectId"
        @update-project="updateProject"
        @close-modal="closeModal"
      ></ModalProjectDelete>
      <ModalBoardDelete
        :is-show="showConfirmBoardDelete"
        :board-id="deleteBoardId"
        @update-board="updateBoard"
        @close-modal="closeModal"
      ></ModalBoardDelete>


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
import Navbar from 'packs/components/common/Navbar'
import Sidebar from 'packs/components/common/Sidebar'
import FormProjectEdit from 'packs/components/modal/FormProjectEdit'
import FormBoardEdit from 'packs/components/modal/FormBoardEdit'
import FormWorkspaceEdit from 'packs/components/modal/FormWorkspaceEdit'
import ModalWorkspaceDelete from 'packs/components/modal/ModalWorkspaceDelete'
import ModalProjectDelete from 'packs/components/modal/ModalProjectDelete'
import ModalBoardDelete from 'packs/components/modal/ModalBoardDelete'
import FlashMessage from 'packs/components/flash/FlashMessage'
import axios from 'axios';

export default {
  name: 'default',
  props: {
    currentUserId: {
      type: Number,
      require: false
    }
  },
  // watch: {
  //   '$route' : {
  //     handler: function(newVal, oldVal) {
  //     }
  //   }
  // },
  data: function () {
    return {
      selected_space_id: 0,
      selected_space_role: 2,
      selected_project_id: 0,
      current_user: {
        id: null,
        email:'',
        name: ''
      },
      workspaces: [],
      projects: [],
      showFormWorkspaceEdit: false,
      showFormProjectEdit: false,
      showFormBoardEdit: false,
      targetProjectIdFormBoard: 0,
      editProjectId: 0,
      showConfirmProjectDelete: false,
      deleteProjectId: 0,
      targetBoardIdFormBoard: 0,
      showConfirmBoardDelete: false,
      deleteBoardId: 0,
      showFlash: false,
      flashMessage: '',
      flashType: '',
      windowWidth: window.innerWidth,
      windowHeight: window.innerHeight,
      isOpenSideMenuSp: false,
      isPC: false,
      breakPoint: 768,
      rstGlobalMenuBtnFlg: false,

      initProjectsLoadedFlg: false,

      showConfirmWorkspaceDelete: false,
      deleteWorkspaceId: 0,
      ws_owner_flg: false
    }
  },
  components: {
    'Navbar': Navbar,
    'Sidebar': Sidebar,
    'FormWorkspaceEdit': FormWorkspaceEdit,
    'FormProjectEdit': FormProjectEdit,
    'FormBoardEdit': FormBoardEdit,
    'ModalWorkspaceDelete': ModalWorkspaceDelete,
    'ModalProjectDelete': ModalProjectDelete,
    'ModalBoardDelete': ModalBoardDelete,
    'FlashMessage': FlashMessage
  },
  created: function() {
    this.initialize()
  },
  mounted: function () {
    window.addEventListener('resize', this.handleResize)
    // this.initialize()
  },
  methods: {
    initialize: async function() {
      const _this = this
      this.fetchCurrentUser()
      this.handleResize()

      await Promise.all([
        this.fetchWorkspaces()
      ])

      switch (this.$route.name) {
        case 'workspace-global':
          this.selected_space_id = 0
          // await Promise.all([
          //   this.fetchProjects()
          // ])
          break;
        case 'workspace':
          
          if (parseInt(this.$route.params.ws_id) >= 1) {
            this.selected_space_id = parseInt(this.$route.params.ws_id)
          } else {
            this.selected_space_id = 0
          }
          // await Promise.all([
          //   this.fetchProjects()
          // ])
          break;
        default:
          break;
      }
    },
    fetchCurrentUser: function () {
      axios.get('/api/users/'+this.currentUserId).then((res) => {
        this.current_user.id = parseInt(res.data.user.id)
        this.current_user.email = res.data.user.email 
        this.current_user.name = res.data.user.name 
      }, (error) => {
        console.log(error);
      });
    },

    fetchWorkspaces: async function () {
      await axios.get('/api/workspaces/').then((res) => {
        this.workspaces = res.data.workspaces
      }, (error) => {
        console.log(error);
      })
    },
    reloadWorkspace: function(target_ws_id) {
      // const target_ws_id = data.value


      if (target_ws_id) {
        const selected_ws = this.workspaces.filter ( (ws) => {
          return  ws.id ==  target_ws_id
        })
        if (selected_ws.length) {
          this.selected_space_role = selected_ws[0].role
        } else {
          this.selected_space_role = 2
        }
      } else {
        this.selected_space_role = 2
      }

      this.selected_space_id = target_ws_id
      this.selected_project_id = 0
      this.fetchProjects()
    },
    fetchProjects: async function () {
      if (this.selected_space_id) {
        if (this.selected_space_role > 0) {
          await axios.get('/api/workspaces/' + this.selected_space_id + '/projects/').then((res) => {
            this.projects = res.data.projects
          }, (error) => {
            console.log(error);
          });
        } else {
          await axios.get('/api/workspaces/' + this.selected_space_id + '/projects/index_manager').then((res) => {
            this.projects = res.data.projects
          }, (error) => {
            console.log(error);
          });
        }
        

      } else {
        await axios.get('/api/projects/').then((res) => {
          this.projects = res.data.projects
        }, (error) => {
          console.log(error);
        });
      }
      this.initProjectsLoadedFlg = true
      
    },
    addProject: function(obj) {
      this.projects.push(obj)
    },
    addBoard: function(obj) {
      this.fetchProjects()
    },
    openFormWorkspaceEdit: function() {
      this.showFormWorkspaceEdit = true
    },
    openFormProjectEdit: function(project_id) {
      this.showFormProjectEdit = true
      this.editProjectId = project_id
    },
    openFormBoardEdit: function(projectid, boardid = 0) {
      this.showFormBoardEdit = true 
      this.targetProjectIdFormBoard = projectid
      this.targetBoardIdFormBoard = boardid
    },
    closeModal: function() {
      this.showConfirmWorkspaceDelete = false
      this.showFormWorkspaceEdit = false
      this.showFormProjectEdit = false
      this.showFormBoardEdit = false
      this.showConfirmProjectDelete = false
      this.deleteWorkspaceId = 0
      this.editProjectId = 0
      this.deleteProjectId = 0
      this.deleteBoardId = 0
      this.showConfirmBoardDelete = false

    },
    getWorkspaceIdFromUrl: function(workspaceid) {
      if (this.selected_space_id != workspaceid || !this.initProjectsLoadedFlg) {
        this.reloadWorkspace(workspaceid)
      }
    },
    getProjectIdFromUrl: function(projectid) {
      this.selected_project_id = projectid
    },
    updateWorkspace: async function() {
      await Promise.all([
        this.fetchWorkspaces()
      ])
      const _this = this
      const selected_ws = this.workspaces.filter ( (ws) => {
        return  ws.id ==  _this.selected_space_id
      })
      if (selected_ws.length) {
        this.selected_space_role = selected_ws[0].role
      } else {
        this.selected_space_role = 2
      }

      this.fetchProjects()
    },
    createWorkspace: async function(add_ws_id) {
      await Promise.all([
        this.fetchWorkspaces()
      ])
      this.$router.push({ name: 'workspace', params: { ws_id: add_ws_id }} ).catch(() => {})
    },
    updateProject: function() {
      this.fetchProjects()
    },
    openConfirmWorkspaceDelete: function(workspace_id) {
      this.showConfirmWorkspaceDelete = true
      this.deleteWorkspaceId = workspace_id
    },
    openConfirmProjectDelete: function(project_id) {
      this.showConfirmProjectDelete = true
      this.deleteProjectId = project_id
    },
    updateBoard: function() {
      this.fetchProjects()
    },
    openConfirmBoardDelete: function(board_id) {
      this.showConfirmBoardDelete = true
      this.deleteBoardId = board_id
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
    handleResize: function() {
      this.windowWidth = window.innerWidth
      this.windowHeight = window.innerHeight
      this.isPC = this.windowWidth >= this.breakPoint
    },
    toggleSideMenu: function(val) {
      this.isOpenSideMenuSp = val
      this.rstGlobalMenuBtnFlg = false
    },
    resetGrobalMenuBtn: function() {
      this.rstGlobalMenuBtnFlg = true
    }
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleResize)
  },
}
</script>

<style lang="scss">
@import url('https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,400;0,500;0,700;1,300;1,400;1,500;1,700&display=swap');
* {
  font-family: 'Roboto', sans-serif;
}
p {
  font-size: 2em;
  text-align: center;
}
.page-container {
  width: 95%;
  margin: 10px auto;
  .page-head {
    // margin-bottom: 20px;
    position: relative;
    padding-bottom: 20px;
    margin-top: 10px;
    @media screen and (min-width: 768px) {
      padding-bottom: 20px;
      // margin-top: 20px;
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
  // input[type="text"] {
  //   &:focus {
  //     background: rgba(255,255,255,0.3)
  //   }
  // }
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
</style>
