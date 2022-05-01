<template>
  <div class="page-container" v-if="Object.keys(board).length" >
    <div class="page-head">
      <h1 v-if="!editNameMode" class="page-title enb-edit" >
        {{board.name}}
        <svg @click.stop="editName" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><!--! Font Awesome Pro 6.0.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2022 Fonticons, Inc. --><path d="M362.7 19.32C387.7-5.678 428.3-5.678 453.3 19.32L492.7 58.75C517.7 83.74 517.7 124.3 492.7 149.3L444.3 197.7L314.3 67.72L362.7 19.32zM421.7 220.3L188.5 453.4C178.1 463.8 165.2 471.5 151.1 475.6L30.77 511C22.35 513.5 13.24 511.2 7.03 504.1C.8198 498.8-1.502 489.7 .976 481.2L36.37 360.9C40.53 346.8 48.16 333.9 58.57 323.5L291.7 90.34L421.7 220.3z"/></svg>
      </h1>
      <h1 v-else class="page-title page-title-edit" >
        <input type="text" v-model="tmpBoardName"  @keyup="checkSubmit">
        <div class="edit-set">
          <span v-if="!enbSubmit" class="submit-btn submit-board-name disable">Save</span>
          <span v-else @click="submitEdit" class="submit-btn submit-board-name">Save</span>
          <span @click="closeEdit" class="cancel-btn cancel-board-name"><i class="fas fa-times"></i></span>
        </div>
      </h1>
      <div v-if="!editDescMode"  class="page-desc enb-edit" >{{board.description}}<svg @click.stop="editDesc" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><!--! Font Awesome Pro 6.0.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2022 Fonticons, Inc. --><path d="M362.7 19.32C387.7-5.678 428.3-5.678 453.3 19.32L492.7 58.75C517.7 83.74 517.7 124.3 492.7 149.3L444.3 197.7L314.3 67.72L362.7 19.32zM421.7 220.3L188.5 453.4C178.1 463.8 165.2 471.5 151.1 475.6L30.77 511C22.35 513.5 13.24 511.2 7.03 504.1C.8198 498.8-1.502 489.7 .976 481.2L36.37 360.9C40.53 346.8 48.16 333.9 58.57 323.5L291.7 90.34L421.7 220.3z"/></svg></div>
      <div v-else class="page-desc page-desc-edit">
        <textarea v-model="tmpBoardDesc"></textarea>
        <div class="edit-set">
          <span v-if="!enbSubmit" class="submit-btn submit-board-desc disable">Save</span>
          <span v-else @click="submitEditDesc" class="submit-btn submit-board-desc">Save</span>
          <span @click="closeEditDesc" class="cancel-btn cancel-board-desc"><i class="fas fa-times"></i></span>
        </div>
      </div>
    </div>

    <section class="main-section">
      <ul class="head-tab-list">
        <li class="head-tab-list__tab" :class="openTabFlg[0]? 'is-active': ''" @click="selTab(0)">
          <h2 v-if="openTabFlg[0]">Ticket List</h2>
          <router-link v-else :to="{ name: 'board', params: { id: board.id } }" class="">Ticket List</router-link>
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
        <li v-if="openTabFlg[0]" class="states-tasks-container">
          <draggable v-model="states" tag="ul" :group="'ITEMS'" :animation="300" class="state-list" @end="onEndStates" >
            <li v-for="(item,index) in states" v-bind:key="index" class="state-list__item">
              <div class="state-list__item__inner">
                <p class="state-list__item__name">{{item.name}}</p>
                <div v-if="!showFormNewTaskList[item.id]" class="add-task-btn" @click.stop="openFormNewTask(item.id)">
                  <span><i class="ooo fas fa-plus"></i></span>
                  <span>Create a Ticket</span>
                </div>
                <div v-else class="form-new-task" >
                  <input type="text" v-model="tmpTaskName[item.id]"  @keyup="checkSubmitTaskName(item.id)" placeholder="Enter Ticket Title" class="form-new-task__input">
                  <div class="edit-set">
                    <span v-if="!enbSubmitTask[item.id]" class="submit-btn submit-board-name disable">Add</span>
                    <span v-else @click="submitAddTask(item.id)" class="submit-btn submit-board-name">Add</span>
                    <span @click="closeFormNewTask(item.id)" class="cancel-btn cancel-board-name"><i class="fas fa-times"></i></span>
                  </div>
                </div>
                <draggable v-model="item.tasks" tag="ul" :group="'ITEMS2'" :animation="300" class="task-list" @end="onEndTasks">
                  <li v-for="(item2,index2) in item.tasks" v-bind:key="index2" class="task-list__item">
                    <a class="task-list__item__link" @click="openTaskTicket(item2.id)">
                      <p class="task-list__item__title">{{item2.title}}</p>
                    </a>
                    <div class="sw-cnt" @click.stop="toggleCntListTask(item2.id)">
                      <i class="fas fa-ellipsis-v"></i>
                    </div>
                    <transition name="fade">
                      <ul v-if="item2.id === selectedCntListTaskId" class="cnt-list">
                        <li class="cnt-list__item" @click="openFormEditTaskTicket(item2.id)" >Edit</li>
                        <li class="cnt-list__item" @click="openFormTaskMove(item2.id)">Move Ticket</li>
                        <li class="cnt-list__item" @click="openConfirmTaskDelete(item2.id)">Delete</li>
                      </ul>
                    </transition>
                  </li>
                </draggable>
              </div>
              <div class="sw-cnt" @click.stop="toggleCntList(item.id)">
                <i class="fas fa-ellipsis-v"></i>
              </div>
              <transition name="fade">
                <ul v-if="item.id === selectedCntListId" class="cnt-list">
                  <li class="cnt-list__item" @click="openFormStateEdit(board.id, item.id)">Edit</li>
                  <li v-if="board.role <= 1" class="cnt-list__item" @click="openConfirmStateDelete(item.id)">Delete</li>
                </ul>
              </transition>
            </li>
          </draggable>
          <div class="add-state-box">
            <div class="state-list__item__inner addbtn" @click="openFormStateEdit(board.id)">
              <span class="icon"><i class="fas fa-plus"></i></span>
              <span class="txt2">New Status</span>
            </div>
          </div>
        </li>

        <li v-if="openTabFlg[1]">
          <BoardMember
            :board="board"
            :current-user="currentUser"
            :members="members"
            @open-form-add-board-member="openFormAddBoardMember"
            @open-form-delete-board-member="openFormDeleteBoardMember"
            @update-board-member="updateBoardMember"
            @open-modal-change-board-orner="openModalChangeBoardOrner"
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
      :current-user="currentUser"
      @close-modal="closeModal"
      :board="board"
      @update-board-member="updateBoardMember"
      @update-board="updateBoard"
      ></FormDeleteBoardMember>
    <ModalChangeBoardOrner
      :is-show="showModalChangeBoardOrner"
      :user="targetMember"
      :current-orner="currentOrner"
      :current-user="currentUser"
      @close-modal="closeModal"
      :board="board"
      @update-board-member="updateBoardMember"
      ></ModalChangeBoardOrner>

    <TaskTicket
      :is-show="showTaskTicket"
      :board="board"
      :members="members"
      :current-user="currentUser"
      @close-modal="closeModal"
      :selected-task-id="editTaskId"
      @update-task="updateTask"
      @open-confirm-task-delete="openConfirmTaskDelete"
      ></TaskTicket>

    <MoveTicket
      :is-show="showMoveTicket"
      :board="board"
      :projects="projects"
      @close-modal="closeModal"
      :selected-task-id="editTaskId"
      @update-task="updateTask"
      ></MoveTicket>

  </div>
</template>
<script>
import BoardMember from 'packs/pages/BoardMember'
import FormAddBoardMember from  'packs/components/modal/FormAddBoardMember'
import FormDeleteBoardMember from 'packs/components/modal/FormDeleteBoardMember'
import ModalChangeBoardOrner from 'packs/components/modal/ModalChangeBoardOrner'
import axios from 'axios';
import draggable from "vuedraggable";
import TaskTicket from 'packs/components/modal/TaskTicket'
import MoveTicket from 'packs/components/modal/MoveTicket'
export default {
  components: {
    BoardMember,
    FormAddBoardMember,
    FormDeleteBoardMember,
    ModalChangeBoardOrner,
    draggable,
    TaskTicket,
    MoveTicket
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
      },
      // deep: true,
      // immediate: true
    },
    'reloadStatesFlg': {
      handler: function(newVal, oldVal) {
        if (newVal) {
          this.fetchStates(parseInt(this.$route.params.id))
        }
      },
      deep: true,
      immediate: true
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
      require: false,
      default: []
    },
    reloadStatesFlg: {
      type: Boolean,
      require: false,
      default: false
    }
  },
  data: function () {
    return {
      workspace: {},
      project: {},
      board: {},
      states: [],
      editNameMode: false,
      editDescMode: false,
      openTabFlg: [false, false, false],
      members: [],
      showFormAddBoardMember: false,
      editBoardId: 0,
      editProjectId: 0,
      showFormDeleteBoardMember: false,
      deleteMember: {},
      targetMember: {},
      currentOrner: {},
      showModalChangeBoardOrner: false,
      selectedCntListId: 0,
      tmpBoardName: null,
      tmpBoardDesc: null,
      enbSubmit: false,
      tmpTaskName: {},
      enbSubmitTask: {},
      showFormNewTaskList: {},
      selectedCntListTaskId: 0,
      // tmpTaskName: {}
      showTaskTicket: false,
      editTaskId: 0,
      initLoaded: false,
      showMoveTicket: false
    }
  },
  mounted() {
    // window.addEventListener('click', this.closeEdit)
    window.addEventListener('click', this.closeCntList)
    window.addEventListener('click', this.closeCntListTask)
    document.addEventListener('keydown', this.onKeyDown)
  },
  created: function() {
    // this.initialize()
    
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
        case 'board-task':
        case 'board-task-edit':
          this.selTab(0)
          const task_id = parseInt(this.$route.params.task_id)
          this.showTaskTicket = true
          this.editTaskId = task_id
          break;
        default:
          this.selTab(0);
          break;
      }
    },
    openFormStateEdit: function(board_id, state_id = 0) {
      this.$emit('open-form-state-edit', board_id, state_id)
    },
    openConfirmStateDelete: function(state_id) {
      this.$emit('open-confirm-state-delete', state_id)
    },
    fetchBoard: function(board_id) {
      axios.get('/api/boards/' + board_id).then((res) => {
        this.board = res.data.board
        this.project = res.data.project
        this.workspace = res.data.workspace
        this.$emit('get-projectid-from-url', this.project.id)
        this.$emit('get-workspaceid-from-url', this.project.workspace_id === null? 0 : this.project.workspace_id)
        if (!this.initLoaded) this.initLoaded = true
      }, (error) => {
        console.log(error);
      });
      this.fetchStates(board_id)
    },
    fetchStates: function(board_id) {
      axios.get('/api/boards/' + board_id + '/states/').then((res) => {
        this.states = res.data.states
        const _this = this
        this.states.forEach(function(state){
          let state_id = state.id
          _this.$set(_this.showFormNewTaskList, state_id, false)
          _this.$set(_this.tmpTaskName, state_id, '')
          _this.$set(_this.enbSubmitTask, state_id, false)
        })
        this.$emit('off-trigger-flg')
      }, (error) => {
        console.log(error);
      });
    },
    editName: function() {
      this.editNameMode = true
      this.tmpBoardName = this.board.name
      this.checkSubmit()
    },
    editDesc: function() {
      this.editDescMode = true
      this.tmpBoardName = this.board.name
      this.tmpBoardDesc = this.board.description
      this.checkSubmit()
    },
    checkSubmit: function() {
      if (this.tmpBoardName && this.tmpBoardName.length) {
        this.enbSubmit = true
      } else {
        this.enbSubmit = false
      }
    },
    submitEdit: function() {
      this.board.name = this.tmpBoardName
      axios.put('/api/boards/' + this.board.id, { board: this.board })
      .then((res) => {
        this.$emit('update-board', this.board.id)
        this.closeEdit()
      }, (error) => {
        console.log(error);
      });
    },
    submitEditDesc: function() {
      this.board.description = this.tmpBoardDesc
      axios.put('/api/boards/' + this.board.id, { board: this.board })
      .then((res) => {
        this.$emit('update-board', this.board.id)
        this.closeEditDesc()
      }, (error) => {
        console.log(error);
      });
    },
    closeEdit: function(event) {
      this.editNameMode = false
      if (this.board.name.length) {
        this.enbSubmit = true
      } else {
        this.enbSubmit = false
      }
    },
    closeEditDesc: function(event) {
      this.editDescMode = false
    },
    reloadBoards: function() {
      this.$emit('update-board', this.board.id)
    },
    toggleCntList: function (state_id) {
      this.selectedCntListId = state_id
    },
    closeCntList: function(event) {
      if (this.selectedCntListId && !this.$el.querySelector('.cnt-list').contains(event.target) && !this.$el.querySelector('.sw-cnt').contains(event.target)) {
        this.selectedCntListId = 0
      }
    },
    toggleCntListTask: function (task_id) {
      this.selectedCntListTaskId = task_id
    },
    closeCntListTask: function(event) {
      if (this.selectedCntListTaskId && !this.$el.querySelector('.cnt-list').contains(event.target) && !this.$el.querySelector('.sw-cnt').contains(event.target)) {
        this.selectedCntListTaskId = 0
      }
    },
    onKeyDown: function (event) {
      if (event.key === 'Escape') {
        if (this.showModalChangeBoardOrner) {
          this.fetchMembers(parseInt(this.$route.params.id))
        }
        this.closeModal()
        this.selectedCntListId = 0
        this.selectedCntListTaskId = 0
      }
    },
    selTab: function (tabid) {
      this.openTabFlg.fill(false)
      const board_id = parseInt(this.$route.params.id)
      this.openTabFlg[tabid] = true
      if (tabid === 1 || this.$route.name || 'board-task' || 'board-task-edit') {
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
      this.targetMember = {}
      this.currentOrner = {}
      this.showModalChangeBoardOrner = false

      this.showTaskTicket = false
      this.editTaskId = 0

      this.showMoveTicket = false
    },
    openFormDeleteBoardMember: function(user) {
      this.deleteMember = user
      this.showFormDeleteBoardMember = true
    },
    updateBoard: function() {
      this.$emit('update-board')
    },
    openModalChangeBoardOrner: function(user, current_orner) {
      this.targetMember = user
      this.currentOrner = current_orner
      this.showModalChangeBoardOrner = true
    },
    onEndStates: function(event) {
      let state_ids = []
      let task_ids = {}
      this.states.forEach(function(state){
        state_ids.push(state.id)
        task_ids[state.id] = []
        if (state.tasks.length) {
          state.tasks.forEach(function(task){
            (task_ids[state.id]).push(task.id)
          })
        }
      })
      let params = {board: {state_ids}}
      axios.put('/api/boards/' + this.board.id + '/update_states', params)
      .then((res) => {
        // this.$emit('update-board', this.board.id)
      }, (error) => {
        console.log(error);
      });
    },
    onEndTasks: function(event) {
      let state_ids = []
      let task_ids = {}
      this.states.forEach(function(state){
        state_ids.push(state.id)
        task_ids[state.id] = []
        if (state.tasks.length) {
          state.tasks.forEach(function(task){
            (task_ids[state.id]).push(task.id)
          })
        }
      })
      let params = {board: {task_ids}}
      axios.put('/api/boards/' + this.board.id + '/update_tasks', params)
      .then((res) => {
        // this.$emit('update-board', this.board.id)
      }, (error) => {
        console.log(error);
      });
    },
    openFormNewTask: function (state_id) {
      this.$set(this.showFormNewTaskList, state_id, true)
      this.$set(this.tmpTaskName, state_id, '')
      this.checkSubmitTaskName(state_id)
    },
    checkSubmitTaskName: function (state_id) {
      if (this.tmpTaskName[state_id] && this.tmpTaskName[state_id].length) {
        this.$set(this.enbSubmitTask, state_id, true)
      } else {
        this.$set(this.enbSubmitTask, state_id, false)
      }
    },
    submitAddTask: function (state_id) {
      const _this = this
      let params = { 
          task : { 
            title: this.tmpTaskName[state_id],
            board_id: this.board.id,
            state_id: state_id
          } 
        }
      axios.post('/api/tasks', params)
        .then((res) => {
          this.states.forEach(function(state, index){
            if (state.id == state_id) {
              _this.states[index].tasks = res.data.tasks
            }
          })
          this.closeFormNewTask(state_id)
        }, (error) => {
          console.log(error);
        });
    },
    closeFormNewTask: function (state_id) {
      this.$set(this.showFormNewTaskList, state_id, false)
      this.$set(this.enbSubmitTask, state_id, false)
      this.$set(this.tmpTaskName, state_id, '')
    },
    openConfirmTaskDelete: function(task_id) {
      this.$emit('open-confirm-task-delete', task_id)
    },
    openTaskTicket: function(task_id) {
      this.showTaskTicket = true
      this.editTaskId = task_id
      this.$router.push({ name: 'board-task', params: { task_id: task_id }} )
    },
    openFormEditTaskTicket: function(task_id) {
      this.showTaskTicket = true
      this.editTaskId = task_id
      this.$router.push({ name: 'board-task-edit', params: { task_id: task_id }} )
    },
    updateTask: function() {
      this.fetchBoard(parseInt(this.$route.params.id))
    },
    openFormTaskMove: function(task_id) {
      this.showMoveTicket = true
      this.editTaskId = task_id
    }
  },
  beforeRouteUpdate (to, from, next) {
    if (to.params.id == from.params.id) {
      this.fetchBoard(parseInt(to.params.id))
    }
    next();
  },
  beforeDestroy() {
    // window.removeEventListener('click', this.closeEdit)
    window.removeEventListener('click', this.closeCntList)
    window.removeEventListener('click', this.closeCntListTask)
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
  .enb-edit {
    svg {
      width: 12px;
      fill: #888;
      cursor: pointer;
      height: 12px;
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
  .states-tasks-container {
    display: flex;
    flex-flow: column;
    @media screen and (min-width:768px) {
      flex-flow: row;
      flex-wrap:nowrap;
      overflow: auto;
    }
  }
  .add-state-box {
    width: 80%;
    margin:0 5px 30px;
    height: 80px;
    @media screen and (min-width: 768px) {
      width: 180px;
      min-width: 180px;
      margin:0 10px 30px;
    }
  }
  .form-new-task {
    margin-bottom: 20px;
  }
  .form-new-task__input {
    width: 100%;
    height: 30px;
    border: none;
    border-radius: 4px;
  }
  .state-list {
    display: flex;
    flex-wrap: wrap;
    justify-content: flex-start;
    flex-flow: column;
    @media screen and (min-width:768px) {
      flex-flow: row;
      flex-wrap:nowrap;
      // overflow: auto;
    }
    &__item {
      width: 100%;
      margin:0 5px 30px;
      position: relative;
      @media screen and (min-width: 768px) {
        width: 80%;
        // width: 240px;
        min-width: 240px;
        margin:0 10px 30px;
        padding: 0 0 50px;
      }
      // &.add-state-box {
      //    @media screen and (min-width: 768px) {
      //     width: 180px;
      //     min-width: 180px;
      //   }
      // }

      &__inner {
        margin: 0 auto;
        width: 100%;
        
        display: block;
        min-height: 180px;
        border-radius: 5px;
        background-color: #f9f7f5;
        box-shadow: 0px 1px 1px 0px rgba(0, 0, 0, .2);
        padding: 8px;
        @media screen and (min-width: 768px) {
          height: 100%;
          max-width: 240px;
          cursor: grab;
          &:active {
            cursor: grabbing;
          }
        }
        
        &.addbtn {
          // padding: 0 0 0 10px;
          cursor: pointer;
          min-height: 48px;
          display: flex;
          justify-content: center;
          align-items: center;
          .icon {
            font-size: 18px;
            margin-right: 16px;
          }
          .txt2 {
            font-size: 18px;
          }
          min-height: 48px;
          &:hover {
            color:  #551a8b;
            opacity: .7;
          }
          @media screen and (min-width: 768px) {
            width: 180px;
            
          }
        }
        
        
      }
      &__name {
        padding: 5px 0 10px;
        color: #000;
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
          color: #551A8B;
          svg {
          opacity: 0.7;
          }
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
  .add-task-btn {
    padding: 5px;
    background-color: #fff;
    border-radius: 6px;
    box-shadow: 1px 2px 1px 1px rgba(155, 155, 155, 0.2);
    margin-bottom: 10px;
    min-height: 30px;
    text-align: center;
    cursor: pointer;
  }
  .task-list {
    min-height: 80px;
    height: calc(100% - 70px);
    &__item {
      position: relative;
      
      background-color: #fff;
      border-radius: 6px;
      box-shadow: 1px 2px 1px 1px rgba(155, 155, 155, 0.2);
      cursor: pointer;
      word-break: break-word;
      margin-bottom: 10px;
      min-height: 60px;
      &:active {
        cursor: grabbing;
        
      }
      &__link {
        min-height: 60px;
        padding: 5px;
        display: flex;
        justify-content: center;
        align-items: center;
      }
      &__title {
        text-align: left;

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
          color: #551A8B;
          svg {
          opacity: 0.7;
          }
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
        z-index: 1;
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