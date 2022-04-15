<template>
  <transition name="modal">
    <div v-if="isShow" id="modal_m1-01" class="modal js-modal" key="modal1">
      <div class="modal__bg js-modal-close" @click="modalClose"></div>
      <div class="modal__content modal__content-project-form">
        <a class="js-modal-close" @click="modalClose"><span></span></a>
        <h4 class="modal_title"><span>{{getMode}} Project</span></h4>
        <p class="modal_txt"><input v-model="project.name" @keyup="checkEnable" type="text" name="name" placeholder="project name"></p>
        <p class="modal_txt"><textarea v-model="project.description" @keyup="checkEnable" name="description"  placeholder="project description"></textarea></p>
        <button v-if="!activeSubmit" class="btnSubmit inActive">{{getBtnText}}</button>
        <button v-else @click="submitProjectData" class="btnSubmit">{{getBtnText}}</button>
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
    selectedSpaceId: {
      type: Number,
      require: false
    },
    projectId: {
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
      project: {
        name: null,
        description: null
      }
    }
  },
  computed: {
    getMode: function () {
      return this.projectId ? 'Edit': 'New'
    },
    getBtnText: function () {
      return this.projectId ? 'Update': 'Create'
    },
  },

  methods: {
    modalClose: function() {
      this.$emit('close-modal')
    },
    submitProjectData: function() {
      if (this.projectId) {
        axios.put('/api/projects/' + this.projectId, { project: this.project })
        .then((res) => {
          // console.log(res)
          this.$emit('update-project', this.project.id)
          this.modalClose()
        }, (error) => {
          console.log(error);
        });
      } else {
        if (this.selectedSpaceId) {
          this.project.workspace_id = this.selectedSpaceId
        }
        axios.post('/api/projects/',{ project: this.project })
        .then((res) => {
          this.$emit('add-project', res.data.project)
          this.project.name = null
          this.project.description = null
          this.project.workspace_id = null
          if (this.project.workspace_id) {
            delete this.project.workspace_id
          }
          this.modalClose()
        }, (error) => {
          console.log(error);
        });
      }
    },
    checkEnable: function() {
      if (this.project.name /*&& this.project.description*/) {
        this.activeSubmit = true
      } else {
        this.activeSubmit = false
      }
    },
    fetchData: function() {
      if (this.projectId) {
        this.$emit('get-projectid-from-url', this.projectId)
        axios.get('/api/projects/' + this.projectId).then((res) => {
          this.project = res.data.project
          this.checkEnable()
        }, (error) => {
          console.log(error);
        });
      } else {
        this.project.name = null,
        this.project.description = null
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