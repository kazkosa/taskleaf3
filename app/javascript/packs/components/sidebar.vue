<template>
  <div id="sidebar" :class="[!isOpenSidebar? 'isClosed':'']">
    <div class="inner">
      <div class="sidebar-toggle-box" @click="opencloseSidebar">
        <svg class="svg-inline--fa fa-bars fa-w-14 tooltips" data-placement="right" data-original-title="Toggle Navigation" aria-hidden="true" focusable="false" data-prefix="fa" data-icon="bars" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" data-fa-i2svg="" data-bs-original-title="" title=""><path fill="currentColor" d="M16 132h416c8.837 0 16-7.163 16-16V76c0-8.837-7.163-16-16-16H16C7.163 60 0 67.163 0 76v40c0 8.837 7.163 16 16 16zm0 160h416c8.837 0 16-7.163 16-16v-40c0-8.837-7.163-16-16-16H16c-8.837 0-16 7.163-16 16v40c0 8.837 7.163 16 16 16zm0 160h416c8.837 0 16-7.163 16-16v-40c0-8.837-7.163-16-16-16H16c-8.837 0-16 7.163-16 16v40c0 8.837 7.163 16 16 16z"></path></svg><!-- <div class="fa fa-bars tooltips" data-placement="right" data-original-title="Toggle Navigation"></div> Font Awesome fontawesome.com -->
      </div>
      <div class="sidebar-main" v-show="isOpenSidebar">
        <div class="user-container">

          <span class="user-container__avatar">{{currentUser.name[0]}}</span>
          <span class="user-container__name">{{currentUser.name}}</span>
        </div>
        <ul class="menu-items">
          <li class="menu-items__item">
            <a href="/dashboard" class="menu-items__item__link">
              <span class="icon"><i class="fas fa-home"></i></span>
              <span class="txt">HOME</span>
            </a>
          </li>
          <li class="menu-items__item">
            <div class="menu-items__item__select-container">
              <span class="icon"><i class="fas fa-subway"></i></span>
              <div class="select-workspaces">
                <selectWrapper
                  :init-text="'Switch Workspace'"
                  :option-list="workspaces"
                ></selectWrapper>
              </div>
            </div>
          </li>
          <li class="menu-items__item">

            <ul class="projects">
              <li class="project" v-for="(item,index) in projects" v-bind:key="index">
                <div class="project__head">
                  <a class="project__head__link" @click="swProjectMenu(index)">
                    <div class="name">
                      <span class="icon_char">{{item.name[0]}}</span>
                      <span>{{item.name}}</span>
                    </div>
                  
                    <div class="btn-openclose" >
                      <span v-show="!isOpenProjects[index]"><i class="fas fa-chevron-down"></i></span>
                      <span v-show="isOpenProjects[index]"><i class="fas fa-chevron-up"></i></span>
                    </div>
                  </a>
                </div>

                <transition>
                  <ul class="boards" v-show="isOpenProjects[index]">
                    <li class="board">
                      <span>board00</span>
                    </li>
                    <li class="board">
                      <span>board00</span>
                    </li>
                    <li class="board">
                      <a class="addbtn">
                        <span class="icon"><i class="fas fa-plus"></i></span>
                        <span class="txt2">Add Board</span>
                      </a>
                    </li>
                  </ul>
                </transition>
              </li>
              <li class="project">
                <a class="addbtn">
                  <span class="icon"><i class="fas fa-plus"></i></span>
                  <span class="txt2">Add Project</span>
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
import selectWrapper from './selectWrapper'

export default {
  props: {
    currentUser: {
      type: Object,
      require: false
    }
  },
  data: function () {
    return {
      message: "Hello Vue!",
      basicMenuOpen: false,
      workspaces: [
        {id:1, name: 'MySpace00'},
        {id:2, name: 'WorkSpace01'}
      ],
      projects: [
        {id:1, name: 'NS'},
        {id:2, name: 'DGE'}
      ],
      isOpenProjects: [],
      isOpenSidebar: true

    }
  },
  created: function() {
    console.log(this.projects)
    const _this =this
    this.projects.forEach(function(v,k){

      _this.isOpenProjects.push(false)
      console.log(_this.isOpenProjects)

    })
  },
  beforeDestroy() {
  },
  
  methods: {
    swProjectMenu: function(n) {
      console.log(n)
      // if (this.)
      console.log(this.isOpenProjects)
      // this.isOpenProjects[n] = !this.isOpenProjects[n]
      
      this.$set(this.isOpenProjects, n, !this.isOpenProjects[n]);

      console.log(this.isOpenProjects)
    },
    opencloseSidebar: function() {
      this.isOpenSidebar = !this.isOpenSidebar
    }
  },
  components: {
    'selectWrapper': selectWrapper,
  },



}
</script>

<style lang="scss">
#sidebar {
  width: 216px;
  min-width: 216px;
  overflow-y: scroll;
  background-color: rgb(255, 255, 255);
  scroll-behavior: smooth;
  border-right: 1px solid rgb(238, 238, 238);
  height: 100%;
  .sidebar-toggle-box {
    text-align: right;
    &:hover {
    opacity: 0.7;
    cursor: pointer;
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
              &__link {
                display: flex;
                justify-content: space-between;
                padding: 0 5px 0 0;
                border-radius: 10px;
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
  max-width: 30px;
  min-width: 0px;
}
</style>