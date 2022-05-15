<template>
  <transition name="modal">
    <div v-if="isShow" id="modal_m1-01" class="modal js-modal" key="modal1">
      <div class="modal__bg js-modal-close" @click="modalClose"></div>
      <div class="modal__content modal__content-project-form">
        <a class="js-modal-close" @click="modalClose"><span></span></a>
        <h4 class="modal_title"><span>Add Project Member</span></h4>

        <div v-if="send_users.length==0" class="modal_txt">
          <input v-model="keyword" @keyup="seaching" type="text" name="keyword" placeholder="Search By Account Email or name">
        </div>

        <div v-else class="modal_txt">
          <ul class="send-item__list">

            <li v-for="(item, index) in send_users" v-bind:key="index" class="project-member-list__member">
              <div class="send-user-item">
                <div class="send-user-item__image-wrapper">
                  {{getInitial(item.name)}}
                </div>
                <div class="send-user-item__info">
                  <p class="user-item__description">{{item.name}}</p>
                  <p class="user-item__email">{{item.email}}</p>
                </div>
                <div class="rmv-send-list" @click="rmvFromSendUserList(item.id)">
                  <span></span>
                </div>
              </div>
            </li>
            <li>
              <input v-model="keyword" @keydown="onKeyDown" @keyup="seaching" type="text" name="keyword" placeholder="" ref="text1">
            </li>
          </ul>

        </div>

        <div class="optional-info">
          <div class="check-form-notify">
            <FormCheckbox
              name="notify"
              text="Notify users"
              v-model="notify"
            ></FormCheckbox>
          </div>
          <div class="select-form-asuthority">
            <SelectWrapper
              :init-text="'Authority'"
              :option-list="getAuthorityList" 
              :init-selected="2"
              @change-value="role = $event"
            ></SelectWrapper>
          </div>
        </div>
        <button @click="submitAddMembers" class="btnSubmit" :class="activeSubmit? '': 'inActive'" >Add</button>

        <div v-if="(users.length && enableDispResult) || message"  class="search-result">
          <ul v-if="users.length && enableDispResult" class="search-result__item-list">
            <li v-for="(item, index) in users" v-bind:key="index" class="project-member-list__member">
              <div class="user-item" @click="moveSendList(item.id)">
                <div class="user-item__image-wrapper">
                  {{getInitial(item.name)}}
                </div>
                <div class="user-item__info">
                  <p class="user-item__description">{{item.name}}</p>
                  <p class="user-item__email">{{item.email}}</p>
                </div>

              </div>
            </li>
          </ul>
          <div v-else-if="message">
            <p class="message">{{message}}</p>
          </div>
        </div>

      </div>
    </div>
  </transition>
</template>
<script>
import axios from 'axios';
import SelectWrapper from '@/components/form/select/SelectWrapper'
import FormCheckbox from '@/components/form/checkbox/FormCheckbox'

export default {
  components: {
    'SelectWrapper': SelectWrapper,
    'FormCheckbox': FormCheckbox
  },
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
    },
    members: {
      type: Array,
      require: true
    },
    currentUser: {
      type: Object,
      require: false
    },
  },
  watch: {
    "isShow": {
      handler: function(newVal, oldVal) {
        if (newVal) {
          this.initialize()
        }
      },
      deep: true,
      immediate: true
    },
    "send_users": {
      handler: function(newVal, oldVal) {
        this.$nextTick(() => {
          if (newVal.length) {
            this.$refs.text1.focus()
          }
        });
      },
      deep: true,
      immediate: true

    }
  },
  created: function() {
    this.initialize()
  },
  data: function () {
    return {
      keyword: '',
      users: [],
      enableDispResult: false,
      message: '',
      exist_user_ids: [],
      exist_user_roles: [],
      send_users: [],
      activeSubmit: false,
      role: 0,
      notify: false

    }
  },
  computed: {
    currentUserRoleInThisPj: function() {
      const tmp = this.members.filter((member)=>{
        return member.user_id == this.currentUser.id
      })
      return (tmp.length && tmp[0].role_before_type_cast >= 0)? tmp[0].role_before_type_cast: 2
    },
    getAuthorityList: function() {
      const _this = this
      const authority_list = [
        // {id:0, name: 'Owner'},
        {id:1, name: 'Manager'},
        {id:2, name: 'Regular'}
      ]
      let target_authority_list = []
      target_authority_list = authority_list.filter( function(item) {
        return  item.id >= _this.currentUserRoleInThisPj
      })

      return target_authority_list

    }
  },
  methods: {
    initialize: function() {
      this.exist_user_ids = []
      this.exist_user_roles = []
      this.exist_user_ids = this.members.map((member) => member.user_id)
      this.exist_user_roles = this.members.map((member) => member.role_before_type_cast)
      this.checkEnable()
    },
    modalClose: function() {
      this.keyword = ''
      this.users = []
      this.role = 0
      this.notify = false
      this.send_users = []
      this.$emit('close-modal')
    },
    seaching: function() {
      if(this.keyword !== "" ){ //空文字対策
        const send_user_ids = this.send_users.map((send_user) => send_user.id)
        const exclude_user_ids = this.exist_user_ids.concat(send_user_ids)
        
        let params = {
          keyword: this.keyword,
          exist_user_ids: exclude_user_ids,
          type: 'project',
          project_id: this.projectId
        }
        if (this.selectedSpaceId) {
          params.workspace_id = this.selectedSpaceId
        }

        axios.get('/api/users/count', {
          params: params
        })
        .then((res) => {

          let display_max = 100;
          if (res.data.count < display_max) {
            this.message = ''
            this.enableDispResult = true

            axios.get('/api/users/', {
              params: params
            })
            .then((res) => {
              this.users = res.data
            }, (error) => {
              console.log(error);
            });
          } else {
            this.enableDispResult = false
            this.message = "Too many hits!\nPlease change the conditions and search again."
          }
        }, (error) => {
          console.log(error);
        });
      } else {
        this.enableDispResult = false
        this.message = ""
      }
    },
    moveSendList: function (userId) {
      let index = this.users.findIndex( user => user.id === userId)
      this.send_users.push(this.users[index])
      this.users.splice(index, 1)
      this.users = []
      this.keyword = ''
      this.checkEnable()
    },
    checkEnable: function() {
      if (this.send_users.length) {
        this.activeSubmit = true
      } else {
        this.activeSubmit = false
      }
    },
    getInitial: function (name) {
      if (name) {
        return name.split(' ').map(function(n){
            return n[0]
        }).join('')
      } else {
        return ''
      }
    },
    submitAddMembers: function() {
      let user_ids_new = this.send_users.map((send_user) => send_user.id)
      let user_ids = this.exist_user_ids.concat(user_ids_new)
      const n = user_ids.length - this.exist_user_roles.length
      let user_roles = this.exist_user_roles
      for (let i=0; i < n; i++) {
        user_roles.push(this.role)
      }

      let sendmail_user_ids = []
      if (this.notify) {
        sendmail_user_ids = user_ids_new
      }


      let params = {
        project: {
          user_ids: user_ids
        },
        project_member: {
          roles: this.exist_user_roles,
          sendmail_user_ids
        }
      }
      if (this.selectedSpaceId) {
        params.project.workspace_id = this.selectedSpaceId
      }
      axios.put('/api/projects/' + this.projectId + '/update_members/', params)
      .then((res) => {
        this.modalClose()
        this.$emit('update-project-member', this.projectId)
      }, (error) => {
        console.log(error);
      });
    },
    rmvFromSendUserList: function(userId) {
      let index = this.send_users.findIndex( send_user => send_user.id === userId)
      this.send_users.splice(index, 1)
    },
    onKeyDown: function(event) {
      if (!this.keyword && event.key === 'Backspace' && this.send_users.length) {
        this.send_users.pop()
      }
    }
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
    }
    .btnSubmit.inActive {
      background-color: #f1f1f1;
      cursor: not-allowed;
      color: #000;
      pointer-events: none;
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
</style>