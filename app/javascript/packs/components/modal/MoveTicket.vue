<template>
  <transition name="modal">
    <div v-if="isShow" id="modal_m1-01" class="modal js-modal" key="modal1">
      <div class="modal__bg js-modal-close" @click="modalClose"></div>
      <div class="modal__content modal__content-task-form">
        <a class="js-modal-close" @click="modalClose"><span></span></a>
        <h1 class="modal_title">
          <span >Move Ticket #{{selectedTaskId}}</span>
        </h1>
        <div class="modal__main">
          <h2>{{task.title}}</h2>
          <div v-if="projects.length" class="form-ctl">
            <label>Project</label>
            <div class="form-ctl__body">
              <SelectWrapper
                :init-text="'Project'"
                :option-list="getSelectProjectList(projects)" 
                :init-selected="initSelectedProjectId"
                @change-value="changeProject"
                :reset="false"
              ></SelectWrapper>
            </div>
          </div>
          
          <div v-if="boards.length" class="form-ctl">
            <label>Board</label>
            <div class="form-ctl__body">
              <SelectWrapper
                :init-text="'Board'"
                :option-list="getSelectBoardList(boards)" 
                :init-selected="initSelectedBoardId"
                @change-value="changeBoard"
                :reset="false"
              ></SelectWrapper>
            </div>
          </div>

          <div v-if="states.length" class="form-ctl">
            <label>Status</label>
            <div class="form-ctl__body">
              <SelectWrapper
                class="move-ticket-select"
                :init-text="'Status'"
                :option-list="getSelectStateList(states)" 
                :init-selected="initSelectedStateId"
                @change-value="changeStatus"
                :reset="false"
              ></SelectWrapper>
            </div>
          </div>

          <div class="btn-container2">
            <button v-if="!activeSubmit" class="btnSubmit inActive">Save</button>
            <button v-else @click="submitMoveTaskData" class="btnSubmit">Save</button>
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
    projects: {
      type: Array,
      require: false,
      default: []
    },
    // members: {
    //   type: Array,
    //   require: false,
    //   default: []
    // },
    // currentUser: {
    //   type: Object,
    //   require: false,
    //   default: {}
    // },
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
          this.initFetchData()
        }
      },
      deep: true,
      immediate: true
    },
  },
  data: function () {
    return {
      activeSubmit: false,
      initSelectedStateId: 0,
      initSelectedBoardId: 0,
      initSelectedProjectId: 0,


      selectedProjectId: 0,
      selectedBoardId: 0,
      selectedStateId: 0,
      // editMode: false,
      task: {},
      taskPre: {},
      boards: [],
      states: []
    }
  },
  computed: {

  },
  methods: {
    modalClose: function() {
      this.$emit('close-modal')
      // this.$router.push({ name: 'board', params: { id: this.board.id }} )
    },
    submitMoveTaskData: function() {
      let params = {
        task: {
          board_id: this.selectedBoardId,
          state_id: this.selectedStateId
        }
      }
      if( this.selectedBoardId == this.initSelectedBoardId ) {
        
      } else {
        params.task.user_id = null
      }
      axios.put('/api/tasks/' + this.selectedTaskId, params)
      .then((res) => {
        this.$emit('update-task')
        this.task = res.data.task
        this.modalClose()
      }, (error) => {
        console.log(error);
      });
      if( this.selectedBoardId == this.initSelectedBoardId ) {

      } else {
        this.$router.push({ name: 'board', params: { id: this.selectedBoardId }} )
      }
    },
    checkEnable: function() {
      if (this.selectedProjectId && this.selectedBoardId && this.selectedStateId) {
        this.activeSubmit = true
      } else {
        this.activeSubmit = false
      }
    },
    fetchBoards: function(project_id) {
      const selectedProject = this.projects.filter((project)=>{
        return project.id == project_id
      })
      if (selectedProject.length) {
        this.boards = selectedProject[0].boards
      } else {
        this.boards = []
      }
    },
    initFetchData: function() {
      if (this.selectedTaskId) {
        axios.get('/api/tasks/' + this.selectedTaskId).then((res) => {
          this.task = res.data.task
          this.selectedStateId = this.initSelectedStateId = this.task.state_id
          this.selectedBoardId = this.initSelectedBoardId = this.task.board_id
          this.selectedProjectId = this.initSelectedProjectId = this.task.project.id

          this.fetchBoards(this.initSelectedProjectId)
          this.states = this.board.states
          this.checkEnable()
        }, (error) => {
          console.log(error);
        });
      } else {
        this.taskPre = {}
        this.initSelectedStateId = 0
      }
    },
    getSelectProjectList: function(projects) {
      let projects_for_option = []
      projects.forEach(function(project){
        projects_for_option.push({
          id: project.id,
          name: project.name
        })
      })
      return projects_for_option
    },
    getSelectBoardList: function(boards) {
      let boards_for_option = []
      boards.forEach(function(board){
        boards_for_option.push({
          id: board.id,
          name: board.name
        })
      })
      return boards_for_option
    },
    getSelectStateList: function(states) {
      let states_for_option = [
        // {id: 0, name: ''}
      ]
      states.forEach(function(state){
        states_for_option.push({
          id: state.id,
          name: state.name
        })
      })
      return states_for_option
    },
    changeProject: function (val) {
      this.selectedProjectId = val
      this.fetchBoards(this.selectedProjectId)
      this.selectedBoardId = 0
      this.initSelectedBoardId = 0
      this.states = []
      this.selectedStateId = 0
      this.initSelectedStateId = 0
      this.checkEnable()
    },
    changeBoard: function (val) {
      this.selectedBoardId = val
      if (this.selectedBoardId && this.selectedBoardId !== this.initSelectedBoardId) {
        this.fetchStates(this.selectedBoardId)
        this.selectedStateId = 0
        this.initSelectedStateId = 0
      } else if (this.selectedBoardId && this.selectedBoardId === this.initSelectedBoardId) {
        this.fetchStates(this.selectedBoardId)
        this.selectedStateId = this.task.state_id
        this.initSelectedStateId = this.task.state_id
      }
      this.checkEnable()
    },
    changeStatus: function (val) {
      this.selectedStateId = val
      this.checkEnable()
    },
    fetchStates: function(board_id) {
      axios.get('/api/boards/' + board_id + '/states/').then((res) => {
        this.states = res.data.states
        
      }, (error) => {
        console.log(error);
      });
    },
  }
}
</script>

<style lang="scss" scoped>
  .move-ticket-select {
    .select-options {
      max-height: 200px;
    }
  }
  .modal__content-task-form {
    max-width: 600px;
    width: 80%;
    max-height: 100vh;
    // overflow: auto;

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