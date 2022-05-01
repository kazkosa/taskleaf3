<template>
  <div id="sidebar" :class="[!isOpenSidebar? 'isClosed':'']">
    <div class="inner">
      <div class="sidebar-toggle-box" @click="opencloseSidebar">
        <img src="../../../images/dashboards/common/side-menu-toggle.svg"  width="14" height="16">
      </div>
      <div class="sidebar-main" v-show="isOpenSidebar">
        <div class="user-container__wrapper">
          <div class="user-container">
            <span class="user-container__avatar">{{getInitial}}</span>
            <span class="user-container__name">{{currentUser.name}}</span>
          </div>
          <a v-if="!isPc" class="btn-logout" href="/logout" data-method="delete"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
        </div>
        <ul class="menu-items">
          <li class="menu-items__item">
            <router-link v-if="selectedSpaceId >= 1" :to="{ name: 'workspace', params: {ws_id: selectedSpaceId}}" class="menu-items__item__link" @click.native="touchLink">
              <span class="icon"><i class="fas fa-home"></i></span>
              <span class="txt">Home</span>
            </router-link>
            <router-link v-else :to="{ name: 'workspace-global' }" class="menu-items__item__link" @click.native="touchLink">
              <span class="icon"><i class="fas fa-home"></i></span>
              <span class="txt">Home</span>
            </router-link>
          </li>
          <li class="menu-items__item menu-items__item-select-container">
            <div class="menu-items__item__select-container">
              <span class="icon"><i class="fas fa-subway"></i></span>
              <div class="select-workspaces">
                <SelectWrapper
                  v-if="workspaces.length"
                  :init-text="'Switch Workspace'"
                  :option-list="getSpaceList"
                  :init-selected="selectedSpaceId"
                  @change-value="changeWorkspace($event)"
                  @open-form-workspace-edit="openFormWorkspaceEdit"
                ></SelectWrapper>
              </div>
            </div>
          </li>
          <li class="menu-items__item">

            <ul class="projects">
              <li class="project" v-for="(item,index) in projects" v-bind:key="index">
                <div class="project__head">
                  <span v-if="checkCurrentProject(item.id)">
                    <div class="name">
                      <span class="icon_char">{{item.name[0]}}</span>
                      <span>{{item.name}}</span>
                    </div>
                  </span>
                  <router-link v-else :to="{ name: 'project', params: { id: item.id }}" class="project__head__link" @click.native="touchLink">
                    <div class="name">
                      <span class="icon_char">{{item.name[0]}}</span>
                      <span>{{item.name}}</span>
                    </div>
                  </router-link>
                  
                  <div v-if="item.boards && item.boards.length" class="project__head__toggle" @click="swProjectMenu(index)">
                    <div class="btn-openclose" >
                      <span v-show="!isOpenProjects[index]"><i class="fas fa-chevron-down"></i></span>
                      <span v-show="isOpenProjects[index]"><i class="fas fa-chevron-up"></i></span>
                    </div>
                  </div>
                </div>

                <transition>
                  <ul class="boards" v-show="isOpenProjects[index]">
                    <li class="board" v-for="(item2, index2) in item.boards" v-bind:key="'board' + index2">
                      <span v-if="checkCurrentBoard(item2.id)" class="board__content" >{{item2.name}}</span>
                      <router-link v-else :to="{ name: 'board', params: { id: item2.id }}" class="board__content active" @click.native="touchLink" >{{item2.name}}</router-link>
                    </li>

                    <li class="board">
                      <a v-if="item.role != 2 && item.join" class="addbtn">
                        <span class="icon"><i class="fas fa-plus"></i></span>
                        <span class="txt2" @click="openFormBoardEdit(item.id)">Add Board</span>
                      </a>
                    </li>
                  </ul>
                </transition>
              </li>
              <li v-if="!selectedSpaceId || selectedSpaceRole != 2" class="project">
                <a class="addbtn">
                  <span class="icon"><i class="fas fa-plus"></i></span>
                  <span class="txt2" @click="openFormProjectEdit">Add Project</span>
                </a>
              </li>
            </ul>
          </li>

        </ul>
      </div>

    </div>
  </div>
</template>
<script>

import SelectWrapper from 'packs/components/form/select/SelectWrapperWs'

export default {
  props: {
    currentUser: {
      type: Object,
      require: false
    },
    projects: {
      type: Array,
      require: false
    },
    targetOpenProjectid: {
      type: Number,
      require: false
    },
    triggerMenuSp: {
      type: Boolean,
      require: false,
      default: false
    },
    isPc: {
      type: Boolean,
      require: false,
      default: false
    },

    selectedSpaceId: {
      type: Number,
      require: false,
      default: 0
    },
    selectedSpaceRole: {
      type: Number,
      require: false,
      default: 0
    },
    workspaces: {
      type: Array,
      require: false
    },
  },
  watch: {
    "projects": {
      handler: function(newVal, oldVal) {
        this.initialize()
      },
      deep: true,
      immediate: true
    },
    "targetOpenProjectid": {
      handler: function(newVal, oldVal) {
        this.initialize()
      },
      deep: true,
      immediate: true
    },
    "triggerMenuSp": {
      handler: function(newVal, oldVal) {
        this.toggleMenuSP()
      },
      deep: true,
      immediate: true
    },
    "isPc": {
      handler: function(newVal, oldVal) {
        this.toggleMenuSP()
      },
      deep: true,
      immediate: true
    }
  },
  data: function () {
    return {
      message: "Hello Vue!",
      basicMenuOpen: false,
      // workspaces: [
      //   {id:1, name: 'MySpace00'},
      //   {id:2, name: 'WorkSpace01'}
      // ],
      isOpenProjects: [],
      isOpenSidebar: true,
      breakPoint: 768
    }
  },
  computed: {
    getInitial: function () {
      if (this.currentUser.name) {
        return this.currentUser.name.split(' ').map(function(n){
            return n[0]
        }).join('')
      } else {
        return ''
      }
    },
    getSpaceList: function () {
      let spaceList = [{id:0, name: 'General Space'}]
      // let spaceList = this.workspaces//[{id:0, name: 'MySpace'}]
      // spaceList = spaceList.unshift( {id:0, name: 'MySpace'}) 
      if (this.workspaces.length > 0) {
        spaceList = spaceList.concat(this.workspaces)
      }
      return spaceList
    }
  },
  created: function() {
    this.initialize()
  },
  beforeDestroy() {
  },
  
  methods: {
    initialize: function() {
      const _this =this
      this.isOpenProjects = []
      this.projects.forEach(function(v,k){
        if ( _this.targetOpenProjectid && v.id === _this.targetOpenProjectid ) {
          _this.isOpenProjects.push(true)
        } else {
          _this.isOpenProjects.push(false)
        }
      })
    },
    swProjectMenu: function(n) {
      this.$set(this.isOpenProjects, n, !this.isOpenProjects[n])
    },
    opencloseSidebar: function() {
      this.isOpenSidebar = !this.isOpenSidebar
    },
    openFormProjectEdit: function() {
      this.$emit('open-form-project-edit')
    },
    openFormBoardEdit: function(project_id) {
      this.$emit('open-form-board-edit', project_id)
    },
    toggleMenuSP: function() {
      if (window.innerWidth < this.breakPoint) {
        this.isOpenSidebar = this.triggerMenuSp
      }
    },
    touchLink: function() {
      if (!this.isPc) {
        this.$emit('touch-link-sp')
      }
    },
    checkCurrentProject: function(id) {
      let current_id = 0
      switch(this.$route.name) {
        case 'project':
        case 'project-member':
        case 'project-setting':
          current_id = parseInt(this.$route.params.id)
          break;
      }
      return id === current_id
    },
    checkCurrentBoard: function(id) {
      let current_id = 0
      switch(this.$route.name) {
        case 'board':
        case 'board-member':
        case 'board-setting':
          current_id = parseInt(this.$route.params.id)
          break;
      }
      return id === current_id
    },
    changeWorkspace: function(target_ws_id) {
      if (this.selectedSpaceId != target_ws_id) {
        this.$emit('reload-workspace', target_ws_id)
        if (target_ws_id) {
          this.$router.push({ name: 'workspace', params: { ws_id: target_ws_id }} )
        } else {
          this.$router.push({ name: 'workspace-global' } )
        }
      }
    },
    openFormWorkspaceEdit: function() {
      this.$emit('open-form-workspace-edit')
    }

  },
  components: {
    'SelectWrapper': SelectWrapper,
  },



}
</script>

<style lang="scss">
#sidebar {
  width: 100%;
  
  overflow-y: scroll;
  background-color: rgb(255, 255, 255);
  scroll-behavior: smooth;
  border-right: 1px solid rgb(238, 238, 238);
  height: calc(100vh - 50px);
  transition-duration: .3s;
  position: absolute;
  z-index: 1;
  @media screen and (min-width:768px) {
    width: 216px;
    min-width: 216px;
    position: static;
    z-index: 0;
    height: 100%;

  }
  .sidebar-toggle-box {
    text-align: right;
    display: none;
    svg {
      max-width: 20px;
    }
    &:hover {
    opacity: 0.7;
    cursor: pointer;
    }
    @media screen and (min-width:768px) {
      display: block;
    }
  }
  a:hover {
    opacity: 0.7;
    cursor: pointer;
    background: #EEE;
    color: purple;
  }
  .inner {
    padding: 8px;
    .user-container__wrapper {
      display: flex;
      justify-content: space-between;
      @media screen and (min-width:768px) {
        display: none;
      }
    }
    .btn-logout {
      padding: 0px 10px 0 20px;
      font-weight: bold;
      text-decoration: none;
      color: #000;
      border-radius: 10px;
      width: 150px;
      display: flex;
      align-items: center;
      
      svg {
        width: 30px;
        font-size: 26px;
        vertical-align: middle;
        margin-right: 10px;
      }
      
      span {
        font-size: 12px;
      }
    }
    .user-container {
      width: 100%;
      padding: 8px 0px;
      border-bottom: 1px solid #CECECE;
      &__avatar {
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
    }
    .menu-items {
      margin-top:5px;
      width: 100%;
      &__item {

        height: 40px;
        line-height: 40px;
        display: block;
        box-sizing: border-box;
        &__link {
          width: 100%;
          display: block;
          border-radius: 10px;
          display: flex;
        }
        .icon {
         
          display: inline-block;
          font-size: 20px;
          width: 30px;
        }
        .icon_char {
          width: 30px;
          background: grey;
          color: #FFF;
          border-radius: 10px;
          font-size: 16px;
          display: inline-block;
          height: 30px;
          line-height: 30px;
          text-align: center;
        }
        .txt {
          display: inline-block;
          width: calc(100% - 40px) ;
        }
        .txt2 {
          display: inline-block;
          cursor: pointer;
        }
        // &__link:hover {
        //   background: #EEE;
        //   color: purple;
        // }
        &__select-container {
          margin: 10px 0;
        }
        &__add-container {
          display: flex;
          margin: 20px 0 0 0;
          justify-content: space-between;
        }
        .projects {
          padding: 20px 0 0 0px;
          .project {
            &__head {
              display: flex;
              justify-content: space-between;
              &__link {
                
                padding: 0 5px 0 0;
                border-radius: 10px;
                width: 90%;
              }
              &__toggle {
                
                padding: 0 5px 0 0;
                // border-radius: 10px;
                width: 10%;
                cursor: pointer;
              }
              
            }
            .boards {
              padding: 0 0 0 20px;
              .addbtn {
                display: block;
                text-align: right;
              }
            }
            // .boards.isOpen {
            //   display:block;
            // }
          }
          .addbtn {
            padding: 0 0 0 10px;
            display: block;
            text-align: right;
            .icon {
              font-size: 14px;
            }
            .txt2 {
              font-size: 14px;
            }
          }
        }

        &.menu-items__item-select-container {
          display: block;
          @media screen and (min-width:768px) {
            display: none;
          }
        }
      }
      .select-workspaces {
        height: 40px;
        line-height: 40px;
        display: inline-block;
        width: calc(100% - 40px) ;
        box-sizing: border-box;
        .select-wrapper {
          width: 100%;
        }
      }
    }
  }
  .v-enter-active, .v-leave-active {
    transition: all 0.1s
  }

  .v-enter {
      transform: translateY(-10px);
  }

  .v-enter, .v-leave-to {
      opacity: 0
  }

}
#sidebar.isClosed {
  width: 0;
  // max-width: 30px;
  min-width: 0px;
  @media screen and (min-width:768px) {
    width: 30px;
    max-width: 30px;
  }
}
</style>