<template>
  <transition name="modal">
    <div v-if="isShow" id="modal_m1-01" class="modal js-modal" key="modal1">
      <div class="modal__bg js-modal-close" @click="modalClose"></div>
      <div v-if="ownprojects.length === 0 && ownboards.length === 0" class="modal__content modal__content-project-form">
        <a class="js-modal-close" @click="modalClose"><span></span></a>
        <h4 class="modal_title"><span>Delete {{user.name}} from {{workspace.name}}</span></h4>
        <p class="modal_message">Are you sure you want to delete this member?</p>
        <button @click="deleteWorkspaceMember" class="btnSubmit">Yes</button>
        <button @click="modalClose" class="btnCancel">No</button>
      </div>
      <div v-else class="modal__content modal__content-project-form">
        <a class="js-modal-close" @click="modalClose"><span></span></a>
        <h4 class="modal_title"><span>Cannot delete {{user.name}} from {{workspace.name}}</span></h4>
        <div class="modal_message">
          <p>You need to transfer the permissions or remove <br/>the following projects/boards <br/>
          because {{user.name}} own these projects/boards.</p>

          <table class="permission-table">
            <tr v-if="ownprojects.length">
              <th>Projects:</th>
              <td>
                <ul>
                  <li v-for="item in ownprojects" :key="item.id">
                    <router-link :to="{ name: 'project-member', params: {id: item.id}}">{{item.name}}</router-link>
                  </li>
                </ul>
              </td>
            </tr>
            <tr v-if="ownboards.length">
              <th>Board:</th>
              <td>
                <ul>
                  <li v-for="item in ownboards" :key="item.id">
                    <router-link :to="{ name: 'board-member', params: {id: item.id}}">{{item.name}}</router-link>
                  </li>
                </ul>
              </td>
            </tr>
          </table>
        </div>
        <button @click="modalClose" class="btnCancel">OK</button>
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
    workspace: {
      type: Object,
      require: false
    },
    user: {
      type: Object,
      require: false
    }
  },
  watch: {
    "isShow": {
      handler: function(newVal, oldVal) {
        if (newVal) {
          this.initCheck()
        }
      },
      deep: true,
      immediate: true
    },
  },
  created: function() {

  },
  data: function () {
    return {
      ownprojects: [],
      ownboards: []
    }
  },
  computed: {
    currentUser () {
      return this.$store.getters.getCurrentUser
    },
  },
  methods: {
    initCheck: function() {
      const _this = this
      this.ownprojects = []
      this.ownboards = []
      axios.get('/api/workspaces/'+ this.workspace.id +'/search_child_members',{params: {user_id: _this.user.user_id}}).then((res) => {
        if (res.data.projects) {
          _this.ownprojects = res.data.projects
        }
        if (res.data.boards) {
          _this.ownboards = res.data.boards
        }
      }, (error) => {
        console.log(error);
      });
    },
    modalClose: function() {
      this.$emit('close-modal')
    },
    deleteWorkspaceMember: function() {
      axios.delete('/api/workspace_members/' + this.user.id )
      .then((res) => {
        this.$emit('update-workspace-member')
        this.modalClose()
        if (this.currentUser.id === this.user.user_id) {
          this.$emit('update-workspace')
          this.$router.push({ path: '/' } )
        }
      }, (error) => {
        console.log(error);
      });
      
    },
  }
}
</script>

<style lang="scss" scoped>
  .modal__content-project-form {
    max-width: 520px;
    top: 30%;
    .btnSubmit {
      border: none;
      padding: 10px;
      background-color: #2c7cff;
      border-radius: 5px;
      cursor: pointer;
      color: #fff;
      width: 60px;
      &:hover {
        opacity: 0.7;
      }
    }
    .btnSubmit.inActive {
      background-color: #f1f1f1;
      cursor: not-allowed;
      color: #000;
      pointer-events: none;
    }
    .btnCancel {
      border: 1px solid #2c7cff;
      padding: 10px;
      background-color: #fff;
      border-radius: 5px;
      cursor: pointer;
      color: #2c7cff;
      width: 60px;
      margin-left: 10px;
      &:hover {
        opacity: 0.7;
      }
    }
  }

  .modal__content input[type="text"] {
    max-width: 500px;
    &:focus {
      background-color: #f1f1f1;
    }
    &:focus-visible {
      outline: none;
    }
  }
  .modal__content input[type="checkbox"] {
    width: 12px;
  }
  .optional-info {
    display: flex;
    justify-content: space-between;
  }
  .check-form-notify {
    text-align: left;
  }
  .select-form-asuthority {
    width: 120px;
  }
  .modal__content .modal_txt {
    margin-bottom: 10px;
  }


  .search-result {
    position: absolute;
    width: 100%;
    max-width: 480px;

    padding: 10px;
    background-color: #fff;
    box-shadow: 
      0 3px 5px -1px rgba(0, 0, 0, .2), 
      0 6px 10px 0 rgba(0, 0, 0, .14), 
      0 1px 18px 0 rgba(0, 0, 0, .12);

    .message {
      white-space: pre-wrap;
    }
    &__item-list {
      max-height: 300px;
      overflow: auto;
    }
  }
  .send-item__list {
    display: flex;
    flex-wrap: wrap;
    background-color: #f1f1f1;
    li {
      display: flex;
      align-items: center;
      margin-right: 5px;
      &:nth-child(n+4) {
        margin-bottom: 5px;
      }
    }
  }
  .send-user-item {
    width: 160px;
    display: flex;
    align-items: center;
    height: 30px;
    margin: 0;
    background: #fff;
    border-radius: 8px;
    padding: 0;
    flex: 1 1 100%;
    padding: 5px;
    background-color: #D7EEFF;
  }
  .send-user-item__image-wrapper {
    background-color: #2C7CFF;
    color: #FFF;
    width: 20px;
    height: 20px;
    line-height: 20px;
    text-align: center;
    border-radius: 50%;
    display: inline-block;
    margin-right: 5px;
    font-size: 10px;
  }
  .send-user-item__info {
    flex: 1;
    display: flex;
    flex-flow: column;
    overflow: hidden;
    .user-item__description {
      max-width: 100%;
      margin-bottom: 0;
      font-weight: 600;
      padding-right: 5px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      text-align: left;
      font-size: 12px;
    }
    .user-item__email {
      margin-bottom: 0;
      font-size: 10px;
      color: #4a4a4a;
      padding-right: 5px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      text-align: left;
    }
  }
  .rmv-send-list {
    display: flex;
    align-items: center;
    cursor: pointer;
    span {
      display: block;
      width: 10px;
      height: 10px;
      position: relative;
      &:before {
        content: "";
        display: block;
        width: 100%;
        height: 2px;
        background: #333;
        transform: rotate(45deg);
        transform-origin: 0 50%;
        position: absolute;
        top: 0;
        left: 14%;
      }
      &:after {
        content: "";
        display: block;
        width: 100%;
        height: 2px;
        background: #333;
        transform: rotate(-45deg);
        transform-origin: 100% 50%;
        position: absolute;
        top: 0;
        right: 14%;
      }
    }
  }
  .user-item {
    width: calc(100% - 40px);
    display: flex;
    align-items: center;
    height: 42px;
    margin: 0 20px 10px;
    background: #fff;
    border-radius: 8px;
    padding: 0 15px;
    max-width: calc(100% - 40px);
    flex: 1 1 100%;
    cursor: pointer;
    &:hover {
      background-color: #eee;
    }
  }
  .user-item__image-wrapper {
    background-color: #2C7CFF;
    color: #FFF;
    width: 24px;
    height: 24px;
    line-height: 24px;
    text-align: center;
    border-radius: 50%;
    display: inline-block;
    margin-right: 10px;
    font-size: 12px;
  }
  .user-item__info {
    flex: 1;
    display: flex;
    flex-flow: column;
    overflow: hidden;
    .user-item__description {
      max-width: 100%;
      margin-bottom: 0;
      font-weight: 600;
      padding-right: 5px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      text-align: left;
    }
    .user-item__email {
      margin-bottom: 0;
      font-size: 12px;
      color: #4a4a4a;
      padding-right: 5px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      text-align: left;
    }
  }
  .user-item__tag {
    width: 50px;
    height: 14px;
    margin-right: 10px;
    margin-top: 3px;
    display: flex;
    justify-content: center;
  }
  .user-item__role {
    margin-bottom: 0;
    flex: none;
    width: 182px;
    font-weight: 300;
    font-size: 12px;
  }
  .user-item__remove {
    width: 26px;
    margin-left: 15px;
  } 
  .invisible {
    visibility: hidden !important;
  }
  .permission-table {
    margin: 10px auto;
    th {
      font-weight: bold;
    }
    th, td {
      // border: 1px solid #000;
      padding: 5px;
    }
  }
</style>