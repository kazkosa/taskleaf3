<template>

    <section class="section-project-members">
      <h3>Workspace Member({{members.length}})</h3>
      <div class="cntrol-container">
        <a class="addbtn" @click="openFormAddWorkspaceMember">
          <span class="icon"><i class="fas fa-plus"></i></span>
          <span class="txt2">Add Member</span>
        </a>
      </div>

      <transition-group class="project-member-list" name="items" tag="ul">

        <li v-for="item in members" v-bind:key="item.id" class="project-member-list__member">

          <div class="member-item">
            <div class="member-item__image-wrapper">
              {{getInitial(item.name)}}
            </div>
            <div class="member-item__info">
              <p class="member-item__description">{{item.name}}</p>
              <p class="member-item__email">{{item.email}}</p>
            </div>
            <div class="member-item__tag"></div>
            <div v-if="getAuthorityList(item).length" class="member-item__role">

              <SelectWrapper
                :init-text="'Authority'"
                :option-list="getAuthorityList(item)" 
                :init-selected="item.role_before_type_cast"
                @change-value="changeRole($event, item)"
              ></SelectWrapper>
            </div>
            <div v-else class="member-item__role noedit" >{{ item.role.charAt(0).toUpperCase() + item.role.slice(1)}}</div> 

            <div v-if="getAuthorityList(item).length" class="member-item__remove xinvisible" @click="openFormDeleteWorkspaceeMember(item)">
              <span></span>
            </div>
           
          </div>
        </li>
      </transition-group>

    </section>

 
</template>
<script>
import axios from 'axios'
import SelectWrapper from 'packs/components/form/select/SelectWrapper'

export default {
  components: {
    'SelectWrapper': SelectWrapper
  },
  props: {
    currentUser: {
      type: Object,
      require: false
    },
    workspace: {
      type: Object,
      require: true
    },
    members: {
      type: Array,
      require: true
    }
  },
  computed: {
    currentUserRoleInThisWs: function() {
      const tmp = this.members.filter((member)=>{
        return member.user_id == this.currentUser.id
      })
      return (tmp.length && tmp[0].role_before_type_cast >= 0)? tmp[0].role_before_type_cast: 2
    }
  },
  data: function () {
    return {
    }
  },
  created: function() {
    this.initialize()
  },
  watch: {
    "members": {
      handler: function(newVal, oldVal) {
        // this.initialize()
      },
      deep: true,
      immediate: true
    },
  },
  
  methods: {
    initialize: async function() {
      const workspace_id = parseInt(this.$route.params.ws_id)
      // this.$emit('update-project-member', this.project.id)
    },
    openFormAddWorkspaceMember: function() {
      this.$emit('open-form-add-workspace-member')
    },
    getInitial: function (name) {
      if (name) {
        return  name.split(' ').map(function(n){
          return n[0]
        }).join('')
      } else {
        return ''
      }
    },
    openFormDeleteWorkspaceeMember: function(user) {
      this.$emit('open-form-delete-workspace-member', user)
    },
    changeRole: function(selected_role, user) {
      if (selected_role !== user.role_before_type_cast) {
        axios.put('/api/workspace_members/' + user.id, { workspace_member: {role: selected_role} })
        .then((res) => {
          // console.log(res)
          this.$emit('update-workspace-member', this.workspace.id)
        }, (error) => {
          console.log(error);
        });
      }
    },
    getAuthorityList: function(target_user) {
      const _this = this
      const authority_list = [
        {id:0, name: 'Owner'},
        {id:1, name: 'Manager'},
        {id:2, name: 'Regular'}
      ]
      let target_authority_list = []
      if (this.currentUserRoleInThisWs === 0) {
        if ( this.currentUser.id != target_user.user_id ) {
          target_authority_list = authority_list
        }
      } else if ( this.currentUserRoleInThisWs <= target_user.role_before_type_cast ) {
        target_authority_list = authority_list.filter( function(item) {
          return  _this.currentUserRoleInThisWs <= item.id 
        })
      }
      return target_authority_list

    }
  
  },
  beforeRouteUpdate (to, from, next) {
    // this.fetchBoards(parseInt(to.params.id))
    next();
  }

}
</script>

<style lang="scss" scoped>
.project-member-list {
  margin-top: 20px;
}
.member-item {
  width: calc(100% - 40px);
  display: flex;
  align-items: center;
  height: 62px;
  margin: 0 20px 10px;
  background: #fff;
  border-radius: 8px;
  padding: 0 15px;
  max-width: calc(100% - 40px);
  flex: 1 1 100%;
}
.cntrol-container {
  text-align: right;
}
.subsection .addbtn {
  padding: 10px 0;
  display: inline-block;
}
.addbtn {
  padding: 0 0 0 10px;
  display: inline-block;
  cursor: pointer;
  .icon {
    font-size: 18px;
  }
  .txt2 {
    font-size: 18px;
  }
}
.addbtn:hover {
  color:  #551a8b;
}
.member-item__image-wrapper {
    background-color: #2C7CFF;
    color: #FFF;
    width: 30px;
    height: 30px;
    line-height: 30px;
    text-align: center;
    border-radius: 50%;
    display: inline-block;
    margin-right: 10px;
}
.image-fluid {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center;
  backface-visibility: hidden;
  vertical-align: middle;
    border-style: none;
}
.member-item__info {
  flex: 1;
  display: flex;
  flex-flow: column;
  overflow: hidden;
  .member-item__description {
    max-width: 100%;
    margin-bottom: 0;
    font-weight: 600;
    padding-right: 5px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    text-align: left;
  }
  .member-item__email {
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
.member-item__tag {
  width: 50px;
  height: 14px;
  margin-right: 10px;
  margin-top: 3px;
  display: flex;
  justify-content: center;
}
.member-item__role {
  margin-bottom: 0;
  margin-right: 20px;
  flex: none;
  width: 160px;
  font-weight: 300;
  font-size: 12px;
  &.noedit {
    margin-right: 36px;
    font-size: 16px;
  }
}
.member-item__remove {
  display: flex;
  align-items: center;
  cursor: pointer;
  span {
    display: block;
    width: 16px;
    height: 16px;
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
.invisible {
  visibility: hidden !important;
}

.items-leave-active,
.items-enter-active {
    transition: opacity .5s, transform .5s ease;
}
.items-leave-to,
.items-enter {
    opacity: 0;
    transform: translateX(50px);
}
.items-leave,
.items-enter-to {
    opacity: 1;
}
.items-move {
    transition: transform .5s;
}


  

</style>