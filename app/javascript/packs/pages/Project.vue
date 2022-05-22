<template>
  <div class="page-container" v-if="Object.keys(project).length">
    <div class="page-head">
      <h1 v-if="project.role == 2" class="page-title">{{project.name}}</h1>
      <h1 v-else-if="!editNameMode" class="page-title enb-edit">
        {{project.name}}
        <svg @click.stop="editName" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><!--! Font Awesome Pro 6.0.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2022 Fonticons, Inc. --><path d="M362.7 19.32C387.7-5.678 428.3-5.678 453.3 19.32L492.7 58.75C517.7 83.74 517.7 124.3 492.7 149.3L444.3 197.7L314.3 67.72L362.7 19.32zM421.7 220.3L188.5 453.4C178.1 463.8 165.2 471.5 151.1 475.6L30.77 511C22.35 513.5 13.24 511.2 7.03 504.1C.8198 498.8-1.502 489.7 .976 481.2L36.37 360.9C40.53 346.8 48.16 333.9 58.57 323.5L291.7 90.34L421.7 220.3z"/></svg>
      </h1>
      <h1 v-else class="page-title page-title-edit">
        <input type="text" v-model="tmpProjectName"  @keyup="checkSubmit">
        <div class="edit-set">
          <span v-if="!enbSubmit" class="submit-btn submit-project-name disable">Save</span>
          <span v-else @click="submitEdit" class="submit-btn submit-project-name">Save</span>
          <span @click="closeEdit" class="cancel-btn cancel-project-name"><i class="fas fa-times"></i></span>
        </div>
      </h1>
      
      <p v-if="project.role == 2" class="page-desc">{{project.description}}</p>
      <div v-else-if="!editDescMode"  class="page-desc enb-edit" >{{project.description}}<svg @click.stop="editDesc" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><!--! Font Awesome Pro 6.0.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2022 Fonticons, Inc. --><path d="M362.7 19.32C387.7-5.678 428.3-5.678 453.3 19.32L492.7 58.75C517.7 83.74 517.7 124.3 492.7 149.3L444.3 197.7L314.3 67.72L362.7 19.32zM421.7 220.3L188.5 453.4C178.1 463.8 165.2 471.5 151.1 475.6L30.77 511C22.35 513.5 13.24 511.2 7.03 504.1C.8198 498.8-1.502 489.7 .976 481.2L36.37 360.9C40.53 346.8 48.16 333.9 58.57 323.5L291.7 90.34L421.7 220.3z"/></svg></div>
      <div v-else class="page-desc page-desc-edit">
        <textarea v-model="tmpProjectDesc"></textarea>
        <div class="edit-set">
          <span v-if="!enbSubmit" class="submit-btn submit-project-desc disable">Save</span>
          <span v-else @click="submitEditDesc" class="submit-btn submit-project-desc">Save</span>
          <span @click="closeEditDesc" class="cancel-btn cancel-project-desc"><i class="fas fa-times"></i></span>
        </div>
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
            <a v-if="project.role != 2 && project.join" class="addbtn" @click="openFormBoardEdit(project.id)">
              <span class="icon"><i class="fas fa-plus"></i></span>
              <span class="txt2">Add Board</span>
            </a>
          </div>
          <ul class="project-list">
            <li v-for="(item,index) in project.boards" v-bind:key="index" class="project-list__item">
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
                  <li v-if="item.role <= 1" class="cnt-list__item" @click="openConfirmBoardDelete(item.id)">Delete</li>
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
            @open-modal-change-project-orner="openModalChangeProjectOrner"
          />
        </li>

        <li  v-if="openTabFlg[2]">
          Setting TBD
        </li>


      </ul>
    </section>

    <FormAddProjectMember
      :selected-space-id="selectedSpaceId"
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
      :current-user="currentUser"
      @close-modal="closeModal"
      :project="project"
      :boards="project.boards"
      @update-project-member="updateProjectMember"
      @update-project="updateProject"
      ></FormDeleteProjectMember>
    <ModalChangeProjectOrner
      :is-show="showModalChangeProjectOrner"
      :user="targetMember"
      :current-orner="currentOrner"
      :current-user="currentUser"
      @close-modal="closeModal"
      :project="project"
      @update-project-member="updateProjectMember"
      ></ModalChangeProjectOrner>
  </div>
</template>
<script>
import axios from 'axios';
import ProjectMember from '@/pages/ProjectMember'
import FormAddProjectMember from '@/components/modal/FormAddProjectMember'
import FormDeleteProjectMember from '@/components/modal/FormDeleteProjectMember'
import ModalChangeProjectOrner from '@/components/modal/ModalChangeProjectOrner'
// import axios from 'axios';
export default {
  components: {
    ProjectMember,
    FormAddProjectMember,
    FormDeleteProjectMember,
    ModalChangeProjectOrner
  },
  watch: {
    "projects": {
      handler: function(newVal, oldVal) {
        this.initialize()
      },
      deep: true,
      immediate: true
    },
    '$route' : {
      handler: function(newVal, oldVal) {
        if (newVal.params.id !== oldVal.params.id) {
          this.initialize()
        }
      }
    }
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
    },
  },
  computed: {
    className: function () {
      return this.message.split('').reverse().join('')
    },
    currentUserRoleInThisPj: function() {
      const tmp = this.members.filter((member)=>{
        return member.user_id == this.currentUser.id
      })
      return (tmp.length && tmp[0].role_before_type_cast >= 0)? tmp[0].role_before_type_cast: 2
    }
  },
  data: function () {
    return {
      // boards: [],
      project: {},
      editNameMode: false,
      editDescMode: false,
      selectedCntListId: 0,
      openTabFlg: [false, false, false],
      members: [],
      showFormAddProjectMember: false,
      editProjectId: 0,
      showFormDeleteProjectMember: false,
      deleteMember: {},
      targetMember: {},
      currentOrner: {},
      showModalChangeProjectOrner: false,
      tmpProjectName: null,
      tmpProjectDesc: null,
      enbSubmit: false
    }
  },
  mounted() {
    // window.addEventListener('click', this.closeEdit)
    window.addEventListener('click', this.closeCntList)
    document.addEventListener('keydown', this.onKeyDown)
  },
  created: function() {
    // this.initialize()
  },
  methods: {
    initialize: async function() {
      const project_id = parseInt(this.$route.params.id)
      this.fetchProjectAndBoards(project_id)
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
    fetchProjectAndBoards: function(project_id) {
      this.$emit('get-projectid-from-url', project_id)
      axios.get('/api/projects/' + project_id).then((res) => {
        // this.boards = res.data.boards
        this.project = res.data.project
        this.$emit('get-workspaceid-from-url', this.project.workspace_id === null? 0 : this.project.workspace_id)
      }, (error) => {
        console.log(error);
      });
    },
    editName: function() {
      this.editNameMode = true
      this.tmpProjectName = this.project.name
      this.checkSubmit()
    },
    
    editDesc: function() {
      this.editDescMode = true
      this.tmpProjectName = this.project.name
      this.tmpProjectDesc = this.project.description
      this.checkSubmit()
    },
    checkSubmit: function() {
      if (this.tmpProjectName && this.tmpProjectName.length) {
        this.enbSubmit = true
      } else {
        this.enbSubmit = false
      }
    },
    submitEdit: function() {
      this.project.name = this.tmpProjectName
      axios.put('/api/projects/' + this.project.id, { project: this.project })
      .then((res) => {
        this.$emit('update-project', this.project.id)
        this.closeEdit()
      }, (error) => {
        console.log(error);
      });
    },
    submitEditDesc: function() {
      this.project.description = this.tmpProjectDesc
      axios.put('/api/projects/' + this.project.id, { project: this.project })
      .then((res) => {
        this.$emit('update-project', this.project.id)
        this.closeEditDesc()
      }, (error) => {
        console.log(error);
      });
    },
    closeEdit: function() {
      // let editFlg = false
      // if (this.editNameMode && !this.$el.querySelector('.page-title-edit').contains(event.target)) {
      //   editFlg = true
        this.editNameMode = false
      // }
      // if (this.editDescMode && !this.$el.querySelector('.page-desc-edit').contains(event.target)) {
      //   editFlg = true
      //   this.editDescMode = false
      // }
      // if (editFlg) {
      //   this.updateData()
      // }
    },
    closeEditDesc: function() {
      this.editDescMode = false
    },
    reloadProjects: function() {
      this.$emit('update-project', this.project.id)
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
      this.$emit('update-project')
    },
    closeModal: function() {
      this.showFormAddProjectMember = false
      this.editProjectId = 0
      this.showFormDeleteProjectMember = false
      this.deleteMemberId = 0
      this.targetMember = {}
      this.currentOrner = {}
      this.showModalChangeProjectOrner = false
    },
    openFormDeleteProjectMember: function(user) {
      this.deleteMember = user
      this.showFormDeleteProjectMember = true
    },
    onKeyDown: function (event) {
      if (event.key === 'Escape') {
        if (this.showModalChangeProjectOrner) {
          this.fetchMembers(parseInt(this.$route.params.id))
        }
        this.closeModal()
      }
    },
    openModalChangeProjectOrner: function(user, current_orner) {
      this.targetMember = user
      this.currentOrner = current_orner
      this.showModalChangeProjectOrner = true
    },
    updateProject: function() {
      this.$emit('update-project')
    }
  },
  beforeRouteUpdate (to, from, next) {
    this.fetchProjectAndBoards(parseInt(to.params.id))
    next();
  },
  beforeDestroy() {
    // window.removeEventListener('click', this.closeEdit)
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
  .enb-edit {
    svg {
      width: 12px;
      height: 12px;
      fill: #888;
      cursor: pointer;
    }
  }
  .page-title.enb-edit,
  .page-desc.enb-edit {
    svg {
      margin-left: 20px;
    }
  }
  .edit-set {
    display: flex;
    padding-top: 10px;
    .submit-btn {
      border-radius: 4px;
      background-color: #2c7cff;
      color: #fff;
      font-size:14px;
      padding: 5px 10px;
      margin-right: 5px;
      cursor: pointer;
      &:hover {
        opacity: 0.7;
      }
      &.disable {
        background-color: #f1f1f1;
        cursor: not-allowed;
        color: #000;
        &:hover {
          cursor: not-allowed;
        }
      }
    }
    .cancel-btn {
      font-size:14px;
      border-radius: 4px;
      font-size: 20px;
      border-radius: 4px;
      padding: 2px 6px;
      cursor: pointer;
      &:hover {
        opacity: 0.7;
      }
    }
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
      position: relative;
      background-color: #fff;
      min-height:80px;
      border-radius: 5px;
      box-shadow: 0px 1px 1px 0px rgba(0, 0, 0, .2);
      @media screen and (min-width: 768px) {
        // width: 30%;
        width: 220px;
        margin:0 10px 30px;
      }
      
      &__link {
        // margin: 0 auto;
        width: 100%;
        // max-width: 220px;
        display: block;
        // min-height:80px;
        // border-radius: 5px;
        // background-color: #fff;
        // box-shadow: 0px 1px 1px 0px rgba(0, 0, 0, .2);
        .name {
          padding: 10px;
          color: #000;
        }
      }
      .sw-cnt {
        position: absolute;
        top: 10px;
        right: 10px;
        width: 20px;
        height: 20px;
        text-align: center;
        cursor: pointer;
        vertical-align: middle;
        display: flex;
        align-items: center;
        justify-content: center;
        &:hover {
          color: #551A8B
        }
      }
      .cnt-list {
        display: block;
        position: absolute;
        top: 10px;
        right: 30px;
        padding: 10px;
        box-shadow: 0px 1px 1px 1px rgba(0, 0, 0, .2);
        border-radius: 4px;
        background: #fff;
        li {
          padding: 10px;
          border-top: 1px solid #ccc;
          cursor: pointer;
          &:first-child {
            border-top: none;
          }
          &:hover {
            opacity: 0.7;
          }
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