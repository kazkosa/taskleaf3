<template>
  <div class="page-container" v-if="Object.keys(workspace).length">
    <div class="page-head">
      <h1 v-if="workspace.role >= 2 || !selectedWsId" class="page-title">{{workspace.name}}</h1>
      <h1 v-else-if="!editNameMode" class="page-title enb-edit">
        {{workspace.name}}
        <svg @click.stop="editName" style="height: 12px;width: 12px;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><!--! Font Awesome Pro 6.0.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2022 Fonticons, Inc. --><path d="M362.7 19.32C387.7-5.678 428.3-5.678 453.3 19.32L492.7 58.75C517.7 83.74 517.7 124.3 492.7 149.3L444.3 197.7L314.3 67.72L362.7 19.32zM421.7 220.3L188.5 453.4C178.1 463.8 165.2 471.5 151.1 475.6L30.77 511C22.35 513.5 13.24 511.2 7.03 504.1C.8198 498.8-1.502 489.7 .976 481.2L36.37 360.9C40.53 346.8 48.16 333.9 58.57 323.5L291.7 90.34L421.7 220.3z"/></svg>
      </h1>
      <h1 v-else class="page-title page-title-edit" >
        <input type="text" v-model="tmpWorkspaceName">
        <div class="edit-set">
          <span v-if="!enbSubmit" class="submit-btn submit-workspace-name disable">Save</span>
          <span v-else @click="submitEdit" class="submit-btn submit-workspace-name">Save</span>
          <span @click="closeEdit" class="cancel-btn cancel-workspace-name"><i class="fas fa-times"></i></span>
        </div>
      </h1>
    </div>

    <section class="main-section">
      <ul class="head-tab-list">
        <li class="head-tab-list__tab" :class="openTabFlg[0]? 'is-active': ''" @click="selTab(0)">
          <h2 v-if="openTabFlg[0]">Project List</h2>
          <router-link v-else-if="selectedWsId" :to="{ name: 'workspace', params: { ws_id: selectedWsId } }" class="">Project List</router-link>
          <router-link v-else :to="{ name: 'workspace-global' }" class="">Project List</router-link>
        </li>
        <li v-if="selectedWsId" class="head-tab-list__tab" :class="openTabFlg[1]? 'is-active': ''"  @click="selTab(1)">
          <h2 v-if="openTabFlg[1]">Member List</h2>
          <router-link v-else :to="{ name: 'workspace-member', params: { ws_id: selectedWsId } }" class="">Member List</router-link>
        </li>
        <li v-if="selectedWsId" class="head-tab-list__tab" :class="openTabFlg[2]? 'is-active': ''"  @click="selTab(2)">
          <h2 v-if="openTabFlg[2]">Other Setting</h2>
          <router-link v-else :to="{ name: 'workspace-setting', params: { ws_id: selectedWsId } }" class="">Other Setting</router-link>
        </li>
      </ul>

      <ul class="content-list">
        <li v-if="openTabFlg[0]">
          <div class="control-header">
            <a v-if="!selectedWsId || workspace.role != 2" class="addbtn" @click="openFormProjectNew">
              <span class="icon"><i class="fas fa-plus"></i></span>
              <span class="txt2">Add Project</span>
            </a>
          </div>
          <ul class="project-list">
            <li v-for="(item,index) in projects" v-bind:key="index" class="project-list__item">
              <router-link :to="{ name: 'project', params: { id: item.id }}" class="project-list__item__link">
                <div class="name">
                  <span class="icon_char">{{item.name[0]}}</span>
                  <span>{{item.name}}</span>
                </div>
              </router-link>
              <div v-if="item.role <= 1" class="sw-cnt" @click.stop="toggleCntList(item.id)">
                <i class="fas fa-ellipsis-v"></i>
              </div>
              <transition name="fade">
                <ul v-if="item.role <= 1 && item.id === selectedCntListId" class="cnt-list">
                  <li class="cnt-list__item" @click="openFormProjectEdit(item.id)">Edit</li>
                  <li class="cnt-list__item" @click="openConfirmProjectDelete(item.id)">Delete</li>
                </ul>
              </transition>
            </li>
          </ul>
        </li>

        <li  v-if="openTabFlg[1]">
          <WorkspaceMember
            :workspace="workspace"
            :members="members"
            @open-form-add-workspace-member="openFormAddWorkspaceMember"
            @open-form-delete-workspace-member="openFormDeleteWorkspaceMember"
            @update-workspace-member="updateWorkspaceMember"
            @open-modal-change-workspace-orner="openModalChangeWorkspaceOrner"
          />
        </li>

        <li  v-if="openTabFlg[2]">
          Setting TBD
        </li>
      </ul>
    </section>

    <FormAddWorkspaceMember
      :is-show="showFormAddWorkspaceMember"
      :members="members"
      @close-modal="closeModal"
      :workspace-id="editWorkspaceId"
      @update-workspace-member="updateWorkspaceMember"
      ></FormAddWorkspaceMember>

    <FormDeleteWorkspaceMember
      :is-show="showFormDeleteWorkspaceMember"
      :user="deleteMember"
      @close-modal="closeModal"
      :workspace="workspace"
      @update-workspace-member="updateWorkspaceMember"
      @update-workspace="updateWorkspace"
      ></FormDeleteWorkspaceMember>
    <ModalChangeWorkspaceOrner
      :is-show="showModalChangeWorkspaceOrner"
      :user="targetMember"
      :current-orner="currentOrner"
      @close-modal="closeModal"
      :workspace="workspace"
      @update-workspace-member="updateWorkspaceMember"
      ></ModalChangeWorkspaceOrner>
  </div>
</template>
<script>

import axios from 'axios';
import WorkspaceMember from '@/pages/WorkspaceMember'
import FormDeleteWorkspaceMember from '@/components/modal/FormDeleteWorkspaceMember'
import FormAddWorkspaceMember from '@/components/modal/FormAddWorkspaceMember'
import ModalChangeWorkspaceOrner from '@/components/modal/ModalChangeWorkspaceOrner'
import { mapGetters } from 'vuex'

export default {
  components: {
    WorkspaceMember,
    FormDeleteWorkspaceMember,
    FormAddWorkspaceMember,
    ModalChangeWorkspaceOrner
  },
  watch: {
    '$route' : {
      handler: function(newVal, oldVal) {
        if (newVal.params.ws_id !== oldVal.params.ws_id) {
          this.initialize()
        }
      }
    }
  },
  props: {},
  computed: {
    ...mapGetters({
      currentUser: 'getCurrentUser',
      workspaces: 'getWorkspaces',
      selectedWsId: 'getSelectedWsId',
      projects: 'getProjects'
    })
  },
  data: function () {
    return {
      workspace: {},
      selectedCntListId: 0,
      editNameMode: false,
      openTabFlg: [false, false, false],
      members: [],
      showFormAddWorkspaceMember: false,
      editWorkspaceId: 0,
      showFormDeleteWorkspaceMember: false,
      deleteMember: {},
      targetMember: {},
      currentOrner: {},
      showModalChangeWorkspaceOrner: false,
      tmpProjectName: null,
      enbSubmit: false
    }
  },
  mounted() {
    // window.addEventListener('click', this.closeEdit)
    window.addEventListener('click', this.closeCntList)
    document.addEventListener('keydown', this.onKeyDown)
  },
  created: function() {
    this.initialize()
  },
  methods: {
    initialize: async function() {
      if (this.selectedWsId != parseInt(this.$route.params.ws_id)) {
        this.$store.commit('setSelectedWsId', parseInt(this.$route.params.ws_id))
      }
      this.fetchWorkspaceAndProjects()
      switch (this.$route.name) {
        case 'workspace': this.selTab(0);break;
        case 'workspace-member': 
          this.selTab(1);
        break;
        case 'workspace-setting': this.selTab(2);break;
        default: this.selTab(0);break;
      }
    },
    fetchWorkspace: function() {
      this.workspace = {}
      const _this = this
      if (this.workspaces.length) {
        if (this.selectedWsId ) {
          let tmp = this.workspaces.filter((ws)=>{
            return ws.id == _this.selectedWsId
          })
          this.workspace = tmp[0]? tmp[0]: {}
        } else {
          this.workspace.name = 'General Space'
        }
      }
    },
    fetchWorkspaceAndProjects: function() {
      if (this.selectedWsId != parseInt(this.$route.params.ws_id)) {
        this.$store.commit('setSelectedWsId', parseInt(this.$route.params.ws_id))
      }
      if (this.selectedWsId) {
        axios.get('/api/workspaces/' + this.selectedWsId).then((res) => {
          this.workspace = res.data.workspace
          this.$emit('reload-workspace', this.workspace.id === null? 0 : this.workspace.id)
        }, (error) => {
          console.log(error);
        });
      } else {
        this.workspace.id = 0
        this.workspace.name = 'General Space'
        this.$store.commit('setSelectedWsId', 0)
        this.$emit('reload-workspace', 0)
      }
    },
    openFormProjectNew: function() {
      this.$emit('open-form-project-edit')
    },
    openFormProjectEdit: function (project_id) {
      this.$emit('open-form-project-edit', project_id)
    },
    toggleCntList: function (project_id) {
      this.selectedCntListId = project_id
    },
    closeCntList: function(event) {
      if (this.selectedCntListId && !this.$el.querySelector('.cnt-list').contains(event.target) && !this.$el.querySelector('.sw-cnt').contains(event.target)) {
        this.selectedCntListId = 0
      }
    },
    editName: function() {
      this.editNameMode = true
      this.tmpWorkspaceName = this.workspace.name
      this.checkSubmit()
    },
    checkSubmit: function() {
      if (this.tmpWorkspaceName && this.tmpWorkspaceName.length) {
        this.enbSubmit = true
      } else {
        this.enbSubmit = false
      }
    },
    submitEdit: function() {
      if (this.selectedWsId) {
        this.workspace.name = this.tmpWorkspaceName
        let params  =  {
          workspace: { name: this.workspace.name }
        }
        axios.put('/api/workspaces/' + this.selectedWsId, params)
        .then((res) => {
          this.$emit('update-workspace', this.selectedWsId)
          this.closeEdit()
        }, (error) => {
          console.log(error);
        });
      }
    },
    closeEdit: function(event) {
      this.editNameMode = false
    },
    reloadWorkspaces: function() {
      if (this.selectedWsId) {
        this.$emit('update-workspace', this.selectedWsId)
      }
    },
    openConfirmProjectDelete: function (project_id) {
      this.$emit('open-confirm-project-delete', project_id)
    },
    onKeyDown: function (event) {
      if (event.key === 'Escape') {
        if (this.showModalChangeWorkspaceOrner) {
          this.fetchMembers(parseInt(this.$route.params.ws_id))
        }
        this.closeModal()
      }
    },
    selTab: function (tabid) {
      this.openTabFlg.fill(false)
      this.openTabFlg[tabid] = true
      if (tabid === 1) {
        this.fetchMembers();
      }
    },
    fetchMembers: function() {
      axios.get('/api/workspaces/' + this.selectedWsId + '/workspace_members/').then((res) => {
        this.members = res.data.workspace_members
      }, (error) => {
        console.log(error);
      });
    },
    openFormAddWorkspaceMember: function() {
      this.editWorkspaceId= parseInt(this.$route.params.ws_id)
      this.showFormAddWorkspaceMember = true
    },
    openFormDeleteWorkspaceMember: function(user) {
      this.deleteMember = user
      this.showFormDeleteWorkspaceMember = true
    },
    updateWorkspaceMember: function() {
      this.fetchMembers(parseInt(this.$route.params.ws_id))
      this.$emit('update-workspace')
    },
    closeModal: function() {
      this.showFormAddWorkspaceMember = false
      this.editWorkspaceId = 0
      this.showFormDeleteWorkspaceMember = false
      this.deleteMemberId = 0
      this.targetMember = {}
      this.currentOrner = {}
      this.showModalChangeWorkspaceOrner = false
    },
    openModalChangeWorkspaceOrner: function(user, current_orner) {
      this.targetMember = user
      this.currentOrner = current_orner
      this.showModalChangeWorkspaceOrner = true
    },
    updateWorkspace: function() {
      this.$emit('update-workspace')
    }
  },
  beforeRouteUpdate (to, from, next) {
    if (to.params.ws_id === from.params.ws_id) {
      this.fetchWorkspaceAndProjects(to.params.ws_id)
    } else {

    }
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
.control-header {
  text-align: right;
}
.subsection .addbtn {
  padding: 10px 0;
  display: inline-block;
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
    max-width: 220px;
    margin:0 5px 30px;
    position: relative;
    background-color: #fff;
    min-height:80px;
    border-radius: 5px;
    box-shadow: 0px 1px 1px 0px rgba(0, 0, 0, .2);
    @media screen and (min-width:768px) {
      width: 220px;
      margin:0 10px 30px;
    }
    
    &__link {
      // margin: 0 auto;
      width: 100%;
      
      display: block;
      height: 100%;
      // min-height:80px;
      // border-radius: 5px;
      // background-color: #fff;
      
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
.fade-enter-active, .fade-leave-active {
  transition: opacity .3s;
}
.fade-enter, .fade-leave-to {
  opacity: 0;
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