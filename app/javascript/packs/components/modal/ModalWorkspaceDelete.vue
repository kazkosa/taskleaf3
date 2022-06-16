<template>
  <transition name="modal">
    <div v-if="isShow" id="modal_m1-01" class="modal js-modal" key="modal1">
      <div class="modal__bg js-modal-close" @click="modalClose"></div>
      <div class="modal__content modal__content-project-form">
        <a class="js-modal-close" @click="modalClose"><span></span></a>
        <h4 class="modal_title"><span>Delete Workspace "{{workspace.name}}"</span></h4>
        <p class="modal_message">Are you sure you want to delete this workspace?</p>
        <button @click="deleteWorkspaceData" class="btnSubmit">Yes</button>
        <button @click="modalClose" class="btnCancel">No</button>
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
      require: false
    },
    workspaceId: {
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
      workspace: {
        name: null,
      }
    }
  },
  methods: {
    modalClose: function() {
      this.$emit('close-modal')
    },
    deleteWorkspaceData: function() {
        axios.delete('/api/workspaces/' + this.workspaceId)
        .then((res) => {
          this.$emit('update-workspace')
          this.modalClose()
        }, (error) => {
          console.log(error);
        });
    },
    fetchData: function() {
      if (this.workspaceId) {
        // this.$emit('get-workspaceid-from-url', this.workspaceId)
        axios.get('/api/workspaces/' + this.workspaceId).then((res) => {
          this.workspace = res.data.workspace
        }, (error) => {
          console.log(error);
        });
      } else {
        this.workspace.name = null
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
      width: 60px;
    }
    .btnSubmit.inActive {
      background-color: #f1f1f1;
      cursor: not-allowed;
      color: #000;
    }
    .btnCancel {
      border: 1px solid #2c7cff;
      padding: 10px;
      background-color: #fff;
      border-radius: 5px;
      cursor: pointer;
      color: #2c7cff;
      width: 60px;
    }
  }
</style>