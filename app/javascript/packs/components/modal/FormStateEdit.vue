<template>
  <transition name="modal">
    <div v-if="isShow" id="modal_m1-01" class="modal js-modal" key="modal1">
      <div class="modal__bg js-modal-close" @click="modalClose"></div>
      <div class="modal__content modal__content-project-form">
        <a class="js-modal-close" @click="modalClose"><span></span></a>
        <h4 class="modal_title"><span>{{getMode}} Status</span></h4>
        <p class="modal_txt"><input v-model="state.name" @keyup="checkEnable" type="text" name="name" placeholder="status name"></p>
        <button v-if="!activeSubmit" class="btnSubmit inActive">{{getBtnText}}</button>
        <button v-else @click="submitStateData" class="btnSubmit">{{getBtnText}}</button>
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
    
    boardId: {
      type: Number,
      require: false
    },
    stateId: {
      type: Number,
      require: true
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
      state: {
        name: null
      }
    }
  },
  computed: {
    getMode: function () {
      return this.stateId ? 'Edit': 'New'
    },
    getBtnText: function () {
      return this.stateId ? 'Update': 'Create'
    },
  },
  methods: {
    modalClose: function() {
      this.$emit('close-modal')
    },
    submitStateData: function() {
      if (this.stateId) {
        axios.put('/api/states/' + this.stateId, { state: this.state })
        .then((res) => {
          this.$emit('update-state', this.stateId)
          this.modalClose()
        }, (error) => {
          console.log(error);
        });
      } else {
        axios.post('/api/states/', { state: { name: this.state.name, board_id: this.boardId } })
        .then((res) => {
          this.$emit('add-state', { boardid: this.boardid, data: res.data.state })
          this.state.name = null
          this.modalClose()
        }, (error) => {
          console.log(error);
        });
      }
    },
    checkEnable: function() {
      if (this.state.name) {
        this.activeSubmit = true
      } else {
        this.activeSubmit = false
      }
    },
    fetchData: function() {
      if (this.stateId) {
        axios.get('/api/states/' + this.stateId).then((res) => {
          this.state = res.data.state
          this.checkEnable()
        }, (error) => {
          console.log(error);
        });
      } else {
        this.state.name = null
      }
    }
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