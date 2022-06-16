<template>
  <transition name="modal">
    <div v-if="isShow" id="modal_m1-01" class="modal js-modal" key="modal1">
      <div class="modal__bg js-modal-close" @click="modalClose"></div>
      <div class="modal__content modal__content-task-form">
        <a class="js-modal-close" @click="modalClose"><span></span></a>
        <h1 class="modal_title">
          <span >{{board.name}} - Ticket #{{selectedTaskId}}</span>
        </h1>
        <div class="modal__main" v-if="editMode">
          <div class="form-ctl">
            <input v-model="taskPre.title" @keyup="checkEnable" type="text" name="name" placeholder="Title">
          </div>
          <div class="form-ctl">
            <textarea v-model="taskPre.content" placeholder="Content"></textarea>
          </div>
          <div class="form-ctl">
            <label>Scheduled date</label>
            <div class="form-ctl__body--row">
              <input type="date" v-model="taskPre.scheduled_start_date">
              <span>~</span>
              <input type="date" v-model="taskPre.scheduled_end_date">
            </div>
          </div>
          <div class="form-ctl">
            <label>Actulal date</label>
            <div class="form-ctl__body--row">
              <input type="date" v-model="taskPre.start_date">
              <span>~</span>
              <input type="date" v-model="taskPre.end_date">
            </div>
          </div>
          <div class="form-ctl">
            <label>Status</label>
            <div class="form-ctl__body">
              <SelectWrapper
                v-if="initSelectedState"
                :init-text="'Status'"
                :option-list="getSelectStateList(board.states)" 
                :init-selected="initSelectedState"
                @change-value="changeStatus"
                :reset="false"
              ></SelectWrapper>
            </div>
          </div>

          <div class="form-ctl">
            <label>Person In Charge</label>
            <div class="form-ctl__body" v-if="members.length">
              <SelectWrapper
                v-if="initSelectedState"
                :init-text="'Member'"
                :option-list="getSelectMemberList(members)" 
                :init-selected="initSelectedPIC"
                @change-value="changePIC"
                :reset="false"
              ></SelectWrapper>
            </div>
          </div>
          <div class="btn-container2">
            <button v-if="!activeSubmit" class="btnSubmit inActive">Save</button>
            <button v-else @click="submitTaskData" class="btnSubmit">Save</button>
            <button @click="swithEditMode(false)" class="btnCancel">Cancel Edit Mode</button>
          </div> 
        </div>
        <div class="modal__main" v-else>
          <h2>{{task.title}}</h2>
          <div v-if="task.content" class="form-ctl">
            <p class="form-ctl__text">{{task.content }}</p>
          </div>
          <div v-if="task.scheduled_start_date || task.scheduled_end_date" class="form-ctl">
            <label>Scheduled date</label>
            <div class="form-ctl__body">
              <p class="form-ctl__text">
                <span v-if="task.scheduled_start_date" >{{task.scheduled_start_date.replace(/-/g,'/')}}</span>
                <span>~</span>
                <span v-if="task.scheduled_end_date" >{{task.scheduled_end_date.replace(/-/g,'/')}}</span>
              </p>
            </div>
          </div>
          <div v-if="task.start_date || task.end_date" class="form-ctl">
            <label>Actulal date</label>
            <div class="form-ctl__body">
              <p class="form-ctl__text">
                <span v-if="task.start_date" >{{task.start_date.replace(/-/g,'/')}}</span>
                <span>~</span>
                <span v-if="task.end_date" >{{task.end_date.replace(/-/g,'/')}}</span>
              </p>
            </div>
          </div>
          <div v-if="task.state_id" class="form-ctl">
            <label>Status</label>
            <div class="form-ctl__body">
              <p class="form-ctl__text">{{task.state.name}}</p>
            </div>
          </div>

          <div class="form-ctl">
            <label>Person In Charge</label>
            <div class="form-ctl__body">
              <p class="form-ctl__text" v-if="task.user">{{task.user.name}} ({{task.user.email}})</p>
              <p class="form-ctl__text" v-else>None</p>
            </div>
          </div>

          <div class="btn-container">
            <a @click="swithEditMode(true)" class="to-main-edit">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><!--! Font Awesome Pro 6.1.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2022 Fonticons, Inc. --><path d="M490.3 40.4C512.2 62.27 512.2 97.73 490.3 119.6L460.3 149.7L362.3 51.72L392.4 21.66C414.3-.2135 449.7-.2135 471.6 21.66L490.3 40.4zM172.4 241.7L339.7 74.34L437.7 172.3L270.3 339.6C264.2 345.8 256.7 350.4 248.4 353.2L159.6 382.8C150.1 385.6 141.5 383.4 135 376.1C128.6 370.5 126.4 361 129.2 352.4L158.8 263.6C161.6 255.3 166.2 247.8 172.4 241.7V241.7zM192 63.1C209.7 63.1 224 78.33 224 95.1C224 113.7 209.7 127.1 192 127.1H96C78.33 127.1 64 142.3 64 159.1V416C64 433.7 78.33 448 96 448H352C369.7 448 384 433.7 384 416V319.1C384 302.3 398.3 287.1 416 287.1C433.7 287.1 448 302.3 448 319.1V416C448 469 405 512 352 512H96C42.98 512 0 469 0 416V159.1C0 106.1 42.98 63.1 96 63.1H192z"/></svg>
            </a>
          </div>  
  
        </div>
      </div>
    </div>
  </transition>
</template>
<script>
import axios from 'axios';
import SelectWrapper from '@/components/form/select/SelectWrapper'

export default {
  components: {
    SelectWrapper
  },
  props: {
    isShow: {
      type: Boolean,
      require: true
    },
    
    board: {
      type: Object,
      require: false,
      default: {}
    },
    members: {
      type: Array,
      require: false,
      default: []
    },
    selectedTaskId: {
      type: Number,
      require: false,
      default: 0
    },
  },
  watch: {
    "isShow": {
      handler: function(newVal, oldVal) {
        if (newVal) {
          
          this.fetchData()
        }
      },
      deep: true,
      immediate: true
    },
  },
  data: function () {
    return {
      activeSubmit: false,
      initSelectedState: 0,
      initSelectedPIC: 0,
      editMode: false,
      task: {},
      taskPre: {}
    }
  },
  computed: {
    getMode: function () {
      return this.selectedTaskId ? 'Edit': 'New'
    },
    getBtnText: function () {
      return this.selectedTaskId ? 'Update': 'Create'
    },
  },
  methods: {
    modalClose: function() {
      this.$emit('close-modal')
      this.$router.push({ name: 'board', params: { id: this.board.id }} )
    },
    submitTaskData: function() {
      if (this.selectedTaskId) {
        axios.put('/api/tasks/' + this.selectedTaskId, { task: this.taskPre })
        .then((res) => {
          this.$emit('update-task', this.stateId)
          this.task = res.data.task
          this.editMode = false
          // this.modalClose()
        }, (error) => {
          console.log(error);
        });
      }
    },
    checkEnable: function() {
      if (this.task.title) {
        this.activeSubmit = true
      } else {
        this.activeSubmit = false
      }
    },
    fetchData: function() {
      this.editMode = false

      if (this.selectedTaskId) {
        axios.get('/api/tasks/' + this.selectedTaskId).then((res) => {
          this.task = res.data.task
          this.taskPre = this.task
          this.initSelectedState = this.task.state_id
          this.initSelectedPIC = this.task.user_id? this.task.user_id: 0 
          this.checkEnable()
          if (this.$route.name == 'board-task-edit') {
            this.editMode = true
          }
        }, (error) => {
          console.log(error);
        });
      } else {
        this.taskPre = {}
        this.initSelectedState = 0
        this.initSelectedPIC = 0
      }
    },
    getSelectStateList: function(states) {
      let states_for_option = []
      states.forEach(function(state){
        states_for_option.push({
          id: state.id,
          name: state.name
        })
      })
      return states_for_option
    },
    changeStatus: function (val) {
      this.taskPre.state_id = val
    },
    getSelectMemberList: function(members) {
      let members_for_option = [
        {
          id: 0,
          name: 'None'
        }
      ]
      members.forEach(function(member){
        members_for_option.push({
          id: member.user_id,
          name: member.name + ' (' + member.email + ')'
        })
      })
      return members_for_option
    },
    changePIC: function (val) {
      this.taskPre.user_id = val? val: null
    },
    swithEditMode: function (val) {
      this.editMode = val? val: false
    },
    openConfirmTaskDelete: function(task_id) {
      this.modalClose()
      this.$emit('open-confirm-task-delete', task_id)
    },
  }
}
</script>

<style lang="scss" scoped>
  .modal__main {
    max-height: calc(100vh - 66px);
    overflow: auto;
    padding: 10px;
  }
  .modal__content-task-form {
    max-width: 600px;
    width: 80%;
    max-height: 100vh;

    textarea {
      height: 100px;
    }
    .btnSubmit {
      border: none;
      padding: 10px;
      background-color: #2c7cff;
      border-radius: 5px;
      cursor: pointer;
      color: #fff;
    }
    .btnSubmit.inActive {
      background-color: #f1f1f1;
      cursor: not-allowed;
      color: #000;
    }
    h2 {
      font-size: 22px;
      font-weight: bold;
      text-align: left;
      margin-bottom: 5px;
      margin-top: 5px;
    }
    
    .btn-container {
      display: flex;
      justify-content: flex-end;
      .to-main-edit,
      .to-confirm-remove {
        cursor: pointer;
        display: inline-block;
        margin-left: 10px;
        &:hover {
          opacity: 0.7;
        }
        svg {
          width: 24px;
          height: auto;
        }
      }
      .to-confirm-remove {
        svg {
          width: 20px;
        }
      }
    }
    .btn-container2 {
      position: relative;
      .btnCancel {
        border: 1px solid #2c7cff;
        padding: 10px;
        background-color: #fff;
        position: absolute;
        right: 0;
        border-radius: 5px;
        cursor: pointer;
        color: #2c7cff;
        &:hover {
          opacity: 0.7;
        }
      }
    }
  }
</style>