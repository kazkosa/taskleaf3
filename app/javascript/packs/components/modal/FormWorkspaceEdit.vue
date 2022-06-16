<template>
  <transition name="modal">
    <div v-if="isShow" id="modal_m1-01" class="modal js-modal" key="modal1">
      <div class="modal__bg js-modal-close" @click="modalClose"></div>
      <div class="modal__content modal__content-project-form">
        <a class="js-modal-close" @click="modalClose"><span></span></a>
        <h4 class="modal_title"><span>{{getMode}} Workspace</span></h4>
        <p class="modal_txt"><input v-model="workspace.name" @keyup="checkEnable" type="text" name="name" placeholder="workspace name"></p>
        <button v-if="!activeSubmit" class="btnSubmit inActive">{{getBtnText}}</button>
        <button v-else @click="submitWorkspaceData" class="btnSubmit">{{getBtnText}}</button>
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
    }
  },
  watch: {
  },
  data: function () {
    return {
      workspaceId: 0,
      activeSubmit: false,
      workspace: {
        name: null
      }
    }
  },
  computed: {
    getMode: function () {
      return this.workspaceId ? 'Edit': 'New'
    },
    getBtnText: function () {
      return this.workspaceId ? 'Update': 'Create'
    },
  },

  methods: {
    modalClose: function() {
      this.$emit('close-modal')
    },
    fetchWorkspaces: async function (workspace_id) {
      await Promise.all([
        this.$store.dispatch('fetchWorkspaces')
      ])
      this.$router.push({ name: 'workspace', params: { ws_id: workspace_id }} ).catch(() => {})
    },
    submitWorkspaceData: function() {
      const _this = this
      if (this.workspaceId) {
        axios.put('/api/workspaces/' + this.workspaceId, { workspace: this.workspace })
        .then((res) => {
          this.$emit('update-workspace', res.data.workspace.id)
          this.$router.push({ name: 'workspace', params: { ws_id: res.data.workspace.id }} )
          this.modalClose()
        }, (error) => {
          console.log(error);
        });
      } else {
        axios.post('/api/workspaces/',{ workspace: this.workspace })
        .then((res) => {
          this.fetchWorkspaces(res.data.workspace.id)
          this.workspace.name = null
          this.modalClose()
        }, (error) => {
          console.log(error);
        });
      }
    },
    checkEnable: function() {
      if (this.workspace.name) {
        this.activeSubmit = true
      } else {
        this.activeSubmit = false
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