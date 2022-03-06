<template>
  <div class="page-container" v-if="Object.keys(board).length" >
    <div class="page-head">
      <h1 v-if="!editNameMode" class="page-title" @click="editName" >{{board.name}}</h1>
      <h1 v-else class="page-title page-title-edit" ><input type="text" v-model="board.name"></h1>
      <div v-if="board.description">
        <p v-if="!editDescMode"  class="page-desc" @click="editDesc" >{{board.description}}</p>
        <p v-else class="page-desc page-desc-edit"><textarea v-model="board.description"></textarea></p>
      </div>
    </div>

    <section class="main-section">
      <ul class="head-tab-list">
        <li class="head-tab-list__tab" :class="openTabFlg[0]? 'is-active': ''" @click="selTab(0)">
          <h2 v-if="openTabFlg[0]">Task List</h2>
          <router-link v-else :to="{ name: 'board', params: { id: board.id } }" class="">Task List</router-link>
        </li>
        <li class="head-tab-list__tab" :class="openTabFlg[1]? 'is-active': ''"  @click="selTab(1)">
          <h2 v-if="openTabFlg[1]">Member List</h2>
          <router-link v-else :to="{ name: 'board-member', params: { id: board.id } }" class="">Member List</router-link>
        </li>
        <li class="head-tab-list__tab" :class="openTabFlg[2]? 'is-active': ''"  @click="selTab(2)">
          <h2 v-if="openTabFlg[2]">Other Setting</h2>
          <router-link v-else :to="{ name: 'board-setting', params: { id: board.id } }" class="">Other Setting</router-link>
          
        </li>
      </ul>

      <ul class="content-list">
        <li v-if="openTabFlg[0]">
          <div class="cntrol-container">
            <a class="addbtn" @click="openFormStatusEdit()">
              <span class="icon"><i class="fas fa-plus"></i></span>
              <span class="txt2">Add Status List</span>
            </a>
          </div>
          <ul class="board-list">
            <li v-for="(item,index) in states" v-bind:key="index" class="board-list__item">
              {{item.name}}
            </li>
          </ul>

        </li>

        <li  v-if="openTabFlg[1]">
          <BoardMember
            :board="board"
            :current-user="currentUser"
            :members="members"
            @open-form-add-board-member="openFormAddBoardMember"
            @open-form-delete-board-member="openFormDeleteBoardMember"
            @update-board-member="updateBoardMember"
          />
        </li>

        <li  v-if="openTabFlg[2]">
          Setting TBD
        </li>


      </ul>
    </section>

    <FormAddBoardMember
      :is-show="showFormAddBoardMember"
       :members="members"
       :current-user="currentUser"
      @close-modal="closeModal"
      :board-id="editBoardId"
      :project-id="editProjectId"
      @update-board-member="updateBoardMember"
      ></FormAddBoardMember>
    <FormDeleteBoardMember
      :is-show="showFormDeleteBoardMember"
      :user="deleteMember"
      @close-modal="closeModal"
      :board="board"
      @update-board-member="updateBoardMember"
      ></FormDeleteBoardMember>

  </div>
</template>
<script>
import BoardMember from './board-member'
import FormAddBoardMember from  './FormAddBoardMember'
import FormDeleteBoardMember from  './FormDeleteBoardMember'
import axios from 'axios';
export default {
  components: {
    'BoardMember': BoardMember,
    'FormAddBoardMember': FormAddBoardMember,
    'FormDeleteBoardMember': FormDeleteBoardMember
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
  data: function () {
    return {
      project: {},
      board: {},
      editNameMode: false,
      editDescMode: false,
      openTabFlg: [false, false, false],
      members: [],
      showFormAddBoardMember: false,
      editBoardId: 0,
      editProjectId: 0,
      showFormDeleteBoardMember: false,
      states: [
        { name: 'To Do' },
        { name: 'Doing' },
        { name: 'Done' }
      ],
      deleteMember: {}
    }
  },
  mounted() {
    window.addEventListener('click', this.closeEdit)
    window.addEventListener('click', this.closeCntList)
    document.addEventListener('keydown', this.onKeyDown)
  },
  created: function() {
    this.initialize()
    
  },
  watch: {

  },
  
  methods: {
    initialize: async function() {
      const boardid = parseInt(this.$route.params.id)
      this.fetchBoard(boardid)

      switch (this.$route.name) {
        case 'board':
          this.selTab(0);
          break;
        case 'board-member': 
          this.selTab(1);
          break;
        case 'board-setting':
          this.selTab(2);
          break;
        default:
          this.selTab(0);
          break;
      }
    },
    openFormStatusEdit: function() {
      console.log('openFormStatusEdit')
      // this.$emit('open-form-status-edit', this.board.id)
    },
    fetchBoard: function(board_id) {
      axios.get('/api/boards/' + board_id).then((res) => {
        this.board = res.data.board
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
      axios.put('/api/boards/' + this.board.id, { board: this.board })
      .then((res) => {
        this.$emit('update-board', this.board.id)
      }, (error) => {
        console.log(error);
      });
    },
    onKeyDown: function (event) {
      if (event.key === 'Escape') {
        this.closeModal()
      }
    },
    selTab: function (tabid) {
      this.openTabFlg.fill(false)
      const board_id = parseInt(this.$route.params.id)
      this.openTabFlg[tabid] = true
      if (tabid === 1) {
        this.fetchMembers(board_id);
      }
    },
    fetchMembers: function(board_id) {
      axios.get('/api/boards/' + board_id + '/board_members/').then((res) => {
        this.members = res.data.board_members
      }, (error) => {
        console.log(error);
      });
    },
    openFormAddBoardMember: function() {
      this.editBoardId= parseInt(this.$route.params.id)
      this.editProjectId = this.project.id
      this.showFormAddBoardMember = true
    },
    updateBoardMember: function() {
      this.fetchMembers(parseInt(this.$route.params.id))
    },
    closeModal: function() {
      this.showFormAddBoardMember = false
      this.editBoardId = 0
      this.editProjectId = 0
      this.showFormDeleteBoardMember = false
      this.deleteBoardId = 0
    },
    openFormDeleteBoardMember: function(user) {
      this.deleteMember = user
      this.showFormDeleteBoardMember = true
    },
  },
  beforeRouteUpdate (to, from, next) {
    this.fetchBoard(parseInt(to.params.id))
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

  .board-list {
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