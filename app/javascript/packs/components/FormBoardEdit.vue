<template>
  <transition name="modal">
    <div v-if="isShow" id="modal_m1-01" class="modal js-modal" key="modal1">
      <div class="modal__bg js-modal-close" @click="modalClose"></div>
      <div class="modal__content modal__content-project-form">
        <a class="js-modal-close" @click="modalClose"><span></span></a>
        <h4 class="modal_title"><span>{{getMode}} Board</span></h4>
        <p class="modal_txt"><input v-model="board.name" @keyup="checkEnable" type="text" name="name" placeholder="board name"></p>
        <p class="modal_txt"><textarea v-model="board.description" @keyup="checkEnable" name="description"  placeholder="board description"></textarea></p>
        <button v-if="!activeSubmit" class="btnSubmit inActive">{{getBtnText}}</button>
        <button v-else @click="submitBoardData" class="btnSubmit">{{getBtnText}}</button>
      </div>
    </div>
  </transition>
</template>
<script>
import axios from 'axios';
export default {
  props: {
    isShow: {
      type: Boolean,
      require: true
    },
    projectId: {
      type: Number,
      require: true
    },
    boardId: {
      type: Number,
      require: false
    }
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
      board: {
        name: null,
        description: null
      }
    }
  },
  computed: {
    getMode: function () {
      return this.boardId ? 'Edit': 'New'
    },
    getBtnText: function () {
      return this.boardId ? 'Update': 'Create'
    },
  },
  methods: {
    modalClose: function() {
      this.$emit('close-modal')
    },
    submitBoardData: function() {
      if (this.boardId) {
        axios.put('/api/boards/' + this.boardId, { board: this.board })
        .then((res) => {
          console.log(res)
          this.$emit('update-board', this.boardId)
          this.modalClose()
        }, (error) => {
          console.log(error);
        });
      } else {
        axios.post('/api/boards/', { board: { name: this.board.name, description: this.board.description, project_id: this.projectId } })
        .then((res) => {
          this.$emit('add-board', { projectid: this.projectid, data: res.data.project })
          this.board_name = null
          this.board_discription = null
          this.modalClose()
        }, (error) => {
          console.log(error);
        });
      }
    },
    checkEnable: function() {
      if (this.board.name && this.board.description) {
        this.activeSubmit = true
      } else {
        this.activeSubmit = false
      }
    },
    fetchData: function() {
      if (this.boardId) {
        // this.$emit('get-projectid-from-url', this.projectId)
        axios.get('/api/boards/' + this.boardId).then((res) => {
          this.board = res.data.board
          this.checkEnable()
        }, (error) => {
          console.log(error);
        });

        // axios.get('/api/boards/' + board_id).then((res) => {
        //   console.log(res)
        //   this.board = res.data.board
        // }, (error) => {
        //   console.log(error);
        // });
      } else {
        this.board.name = null,
        this.board.description = null
      }
    },
  }
}
</script>

<style lang="scss" scoped>
  .modal__content-project-form {
    max-width: 400px;
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
  }
</style>