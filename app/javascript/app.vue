<template>
  <div>
    <navbar
      :current-user="current_user"
      @toggle-sidemenu="toggleSideMenu"
    ></navbar>
    <div id="body">
      <sidebar
        ref="sidebar"
        :current-user="current_user"
        :projects="projects"
        :target-open-projectid="selected_project_id"
        @open-form-project-edit="openFormProjectEdit"
        @open-form-board-edit="openFormBoardEdit"
        :trigger-menu-sp="isOpenSideMenuSp"
        :is-pc="isPC"
      ></sidebar>
      <main>
        <div class="container">
          <router-view
            ref="page"
            :current-user="current_user"
            :selected-space-id="selected_space_id"
            :projects="projects"
            @open-form-project-edit="openFormProjectEdit"
            @open-form-board-edit="openFormBoardEdit"
            @get-projectid-from-url="getProjectIdFromUrl"
            @update-project="updateProject"
            @open-confirm-project-delete="openConfirmProjectDelete"
            @open-confirm-board-delete="openConfirmBoardDelete"
            @flash-on="flashOn"
            @keypress.esc="closeModal"
          ></router-view>
        </div>
      </main>

      <FormProjectEdit
        :is-show="showFormProjectEdit"
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
import navbar from './packs/components/navbar'
import sidebar from './packs/components/sidebar'
import FormProjectEdit from './packs/components/FormProjectEdit'
import FormBoardEdit from './packs/components/FormBoardEdit'
import ModalProjectDelete from './packs/components/ModalProjectDelete'
import ModalBoardDelete from './packs/components/ModalBoardDelete'
import FlashMessage from './packs/components/FlashMessage'
import axios from 'axios';

export default {
  props: {
    currentUserId: {
      type: Number,
      require: false
    }
  },
  data: function () {
    return {
      selected_space_id: 0,
      selected_project_id: 0,
      current_user: {
        id: null,
        email:'',
        name: ''
      },
      projects: [],
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
      breakPoint: 768
    }
  },
  components: {
    'navbar': navbar,
    'sidebar': sidebar,
    'FormProjectEdit': FormProjectEdit,
    'FormBoardEdit': FormBoardEdit,
    'ModalProjectDelete': ModalProjectDelete,
    'ModalBoardDelete': ModalBoardDelete,
    'FlashMessage': FlashMessage
  },
  mounted: function () {
    window.addEventListener('resize', this.handleResize)
    this.initialize()
  },
  methods: {
    initialize: function() {
      this.fetchCurrentUser()
      this.handleResize()
      if (!this.selected_space_id) {
        this.fetchProjects()
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
    fetchProjects: function () {
      axios.get('/api/projects/').then((res) => {
        this.projects = res.data.projects
      }, (error) => {
        console.log(error);
      });
    },
    addProject: function(obj) {
      this.projects.push(obj)
    },
    addBoard: function(obj) {
      this.fetchProjects()
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
      this.showFormProjectEdit = false
      this.showFormBoardEdit = false
      this.showConfirmProjectDelete = false
      this.editProjectId = 0
      this.deleteProjectId = 0
      this.deleteBoardId = 0
      this.showConfirmBoardDelete = false
    },
    getProjectIdFromUrl: function(projectid) {
      this.selected_project_id = projectid
    },
    updateProject: function() {
      this.fetchProjects()
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
