<template>
  <div class="page-container" v-if="Object.keys(project).length">
    <div class="page-head">
      <h1 v-if="!editNameMode" class="page-title" @click="editName" >{{project.name}}</h1>
      <h1 v-else class="page-title page-title-edit" ><input type="text" v-model="project.name"></h1>
      <div v-if="project.description">
        <p v-if="!editDescMode"  class="page-desc" @click="editDesc" >{{project.description}}</p>
        <p v-else class="page-desc page-desc-edit"><textarea v-model="project.description"></textarea></p>
      </div>
    </div>
    <section class="main-section">
      <ul class="head-tab-list">
        <li class="head-tab-list__tab" :class="openTabFlg[0]? 'is-active': ''" @click="selTab(0)">
          <h2 v-if="openTabFlg[0]">Board List</h2>
          <router-link v-else :to="{ name: 'project', params: { id: project.id } }" class="">Board List</router-link>
        </li>
        <li class="head-tab-list__tab" :class="openTabFlg[1]? 'is-active': ''"  @click="selTab(1)">
          <h2 v-if="openTabFlg[1]">Member List</h2>
          <router-link v-else :to="{ name: 'project-member', params: { id: project.id } }" class="">Member List</router-link>
        </li>
        <li class="head-tab-list__tab" :class="openTabFlg[2]? 'is-active': ''"  @click="selTab(2)">
          <h2 v-if="openTabFlg[2]">Other Setting</h2>
          <router-link v-else :to="{ name: 'project-setting', params: { id: project.id } }" class="">Other Setting</router-link>
          
        </li>
      </ul>

      <ul class="content-list">
        <li v-if="openTabFlg[0]">
          <div class="cntrol-container">
            <a class="addbtn" @click="openFormBoardEdit(project.id)">
              <span class="icon"><i class="fas fa-plus"></i></span>
              <span class="txt2">Create New Board</span>
            </a>
          </div>
          <ul class="project-list">
            <li v-for="(item,index) in boards" v-bind:key="index" class="project-list__item">
              <router-link :to="{ name: 'board', params: { id: item.id }}" class="project-list__item__link">
                <div class="name">
                  <span class="icon_char">{{item.name[0]}}</span>
                  <span>{{item.name}}</span>
                </div>
              </router-link>
              <div class="sw-cnt" @click.stop="toggleCntList(item.id)">
                <i class="fas fa-ellipsis-v"></i>
              </div>
              <transition name="fade">
                <ul v-if="item.id === selectedCntListId" class="cnt-list">
                  <li class="cnt-list__item" @click="openFormBoardEdit(project.id, item.id)">Edit</li>
                  <li class="cnt-list__item" @click="openConfirmBoardDelete(item.id)">Delete</li>
                </ul>
              </transition>
            </li>
          </ul>

        </li>

        <li  v-if="openTabFlg[1]">
          <ProjectMember
            :project="project"
            :current-user="currentUser"
            :members="members"
            @open-form-add-project-member="openFormAddProjectMember"
            @open-form-delete-project-member="openFormDeleteProjectMember"
            @update-project-member="updateProjectMember"
          />
        </li>

        <li  v-if="openTabFlg[2]">
          Setting TBD
        </li>


      </ul>
    </section>


    <FormAddProjectMember
      :is-show="showFormAddProjectMember"
       :members="members"
       :current-user="currentUser"
      @close-modal="closeModal"
      :project-id="editProjectId"
      @update-project-member="updateProjectMember"
      ></FormAddProjectMember>
    <FormDeleteProjectMember
      :is-show="showFormDeleteProjectMember"
      :user="deleteMember"
      @close-modal="closeModal"
      :project="project"
      @update-project-member="updateProjectMember"
      ></FormDeleteProjectMember>

  </div>
</template>
<script>
import ProjectMember from './project-member'
import FormAddProjectMember from  './FormAddProjectMember'
import FormDeleteProjectMember from  './FormDeleteProjectMember'
import axios from 'axios';
export default {
  components: {
    'ProjectMember': ProjectMember,
    'FormAddProjectMember': FormAddProjectMember,
    'FormDeleteProjectMember': FormDeleteProjectMember
  },
  props: {
    currentUser: {
      type: Object,
      require: false
    },
    selectedSpaceId: {
      type: Number,
      require: false
    },
    projects: {
      type: Array,
      require: false
    }
  },
  computed: {
    className: function () {
      return this.message.split('').reverse().join('')
    }
  },

  data: function () {
    return {
      boards: [],
      project: {},
      editNameMode: false,
      editDescMode: false,
      selectedCntListId: 0,
      openTabFlg: [false, false, false],
      members: [],
      showFormAddProjectMember: false,
      editProjectId: 0,
      showFormDeleteProjectMember: false,
      deleteMember: {}
      
    }
  },
  mounted() {
    window.addEventListener('click', this.closeEdit)
    window.addEventListener('click', this.closeCntList)
    document.addEventListener('keydown', this.onKeyDown)
  },
  created: function() {
    // this.initialize()
    
  },
  watch: {
    "projects": {
      handler: function(newVal, oldVal) {
        if (newVal.length) {
          this.initialize()
        }
      },
      deep: true,
      immediate: true
    },
    '$route' : {
      handler: function(newVal, oldVal) {
        if (newVal.params.id !== oldVal.params.id) {
          this.initialize()
        }
      },
      // deep: true,
      // immediate: true
    }
  },
  methods: {
    initialize: async function() {
      const project_id = parseInt(this.$route.params.id)
      this.fetchBoards(project_id)
     
      switch (this.$route.name) {
        case 'project': this.selTab(0);break;
        case 'project-member': 
          this.selTab(1);
        break;
        case 'project-setting': this.selTab(2);break;
        default: this.selTab(0);break;
      }
     
    },
    openFormBoardEdit: function(projectid, boardid = 0 ) {
      this.$emit('open-form-board-edit', projectid, boardid)
    },
    fetchBoards: function(project_id) {
      this.$emit('get-projectid-from-url', project_id)
      axios.get('/api/projects/' + project_id).then((res) => {
        this.boards = res.data.boards
        this.project = res.data.project
      }, (error) => {
        console.log(error);
      });
    },
    editName: function() {
      this.editNameMode = true
    },
    
    editDesc: function() {
      this.editDescMode = true
    },
    closeEdit: function(event) {
      let editFlg = false
      if (this.editNameMode && !this.$el.querySelector('.page-title-edit').contains(event.target)) {
        editFlg = true
        this.editNameMode = false
      }
      if (this.editDescMode && !this.$el.querySelector('.page-desc-edit').contains(event.target)) {
        editFlg = true
        this.editDescMode = false
      }
      if (editFlg) {
        this.updateData()
      }
      
    },
    updateData: function() {
      axios.put('/api/projects/' + this.project.id, { project: this.project })
      .then((res) => {
        this.$emit('update-project', this.project.id)
      }, (error) => {
        console.log(error);
      });
    },
    toggleCntList: function (board_id) {
      this.selectedCntListId = board_id
    },
    closeCntList: function(event) {
      if (this.selectedCntListId && !this.$el.querySelector('.cnt-list').contains(event.target) && !this.$el.querySelector('.sw-cnt').contains(event.target)) {
        this.selectedCntListId = 0
      }
    },
    openConfirmBoardDelete: function (board_id) {
      this.$emit('open-confirm-board-delete', board_id)

    },
    selTab: function (tabid) {
      this.openTabFlg.fill(false)
      const project_id = parseInt(this.$route.params.id)
      this.openTabFlg[tabid] = true
      if (tabid === 1) {
        this.fetchMembers(project_id);
      }
    },
    fetchMembers: function(project_id) {
      axios.get('/api/projects/' + project_id + '/project_members/').then((res) => {
        this.members = res.data.project_members
      }, (error) => {
        console.log(error);
      });

    },
    openFormAddProjectMember: function() {
      this.editProjectId= parseInt(this.$route.params.id)
      this.showFormAddProjectMember = true
    },
    updateProjectMember: function() {
      this.fetchMembers(parseInt(this.$route.params.id))
    },
    closeModal: function() {
      this.showFormAddProjectMember = false
      this.editProjectId = 0
      this.showFormDeleteProjectMember = false
      this.deleteMemberId = 0
    },
    openFormDeleteProjectMember: function(user) {
      this.deleteMember = user
      this.showFormDeleteProjectMember = true
    },
    onKeyDown: function (event) {
      if (event.key === 'Escape') {
        this.closeModal()
      }
    }
  },
  beforeRouteUpdate (to, from, next) {
    this.fetchBoards(parseInt(to.params.id))
    next();
  },
  beforeDestroy() {
    window.removeEventListener('click', this.closeEdit)
    window.removeEventListener('click', this.closeCntList)
    document.removeEventListener('keydown', this.onKeyDown)
  }
  

}
</script>

<style lang="scss" scoped>
  
  .icon_char {
    width: 30px;
    background: grey;
    color: #FFF;
    border-radius: 10px;
    font-size: 16px;
    display: inline-block;
    height: 30px;
    line-height: 30px;
    text-align: center;
  }
  .cntrol-container {
    text-align: right;
  }
  .addbtn {
    padding: 0 0 0 10px;
    display: inline-block;
    cursor: pointer;
    .icon {
      font-size: 18px;
    }
    .txt2 {
      font-size: 18px;
    }
  }
  .addbtn:hover {
    color:  #551a8b;
  }

  .project-list {
    display: flex;
    flex-wrap: wrap;
    justify-content: flex-start;
    flex-flow: column;
    @media screen and (min-width:768px) {
      flex-flow: row;
      flex-wrap: wrap;
    }
    &__item {
      
      width: 80%;
      margin:0 5px 30px;
      @media screen and (min-width: 768px) {
        // width: 30%;
        width: 220px;
        margin:0 10px 30px;
      }
      
      &__link {
        margin: 0 auto;
        width: 100%;
        max-width: 220px;
        display: block;
        min-height:80px;
        border-radius: 5px;
        background-color: #fff;
        box-shadow: 0px 1px 1px 0px rgba(0, 0, 0, .2);
        .name {
          padding: 10px;
          color: #000;
        }
      }
    }
  }
  .head-tab-list {
    display: flex;
    h2 {
      display: inline-block;
    }
    &__tab {
      &:first-child {
        margin-left: 16px;
      }
      &:nth-child(n+2){
        margin-left: 8px;
      }
      padding: 10px;
      background-color: #f3f3f3;
      a {
        color: #888;
      }
      h2 {
        color: #000;
        position: relative;
      }
      position: relative;
      &:after {
        content: '';
        position: absolute;
        width: 0%;
        height: 0px;
        border: none;
        opacity: 0;
        transition-duration: .3s;
        background-color : #551a8b;
        bottom: 0px;
        left: 50%;
        transform: translateX(-50%)
      }
      &.is-active {
        background-color: #f3f3f3;
        h2 {
          color: #000;
        }
         &:after {
          opacity: 1;
          width: 50%;
          height: 2px;
        }
      }
    }
  }
  .content-list {
    padding: 20px 10px;
    @media screen and (min-width: 768px) {
      padding: 20px;
    }
  }
  
</style>