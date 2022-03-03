<template>
    <header id="header">
      <div class="inner">
        <div class="header-logo-container">
          <a href="/dashboard" class="imgBox">
            <img src="../../images/dashboards/common/logoTop2.png" alt="TicketLine" width="160" height="37" class="logo-top">
          </a>
        </div>

        <div>
          <ul class="menulist">
            <li class="menu">
              <div class="icon-container">
                <div class="round-btn icon-box drop-down-btn" @click="dropMenu">
                  <span v-show="!basicMenuOpen"><i class="fas fa-caret-down clickicon"></i></span>
                  <span v-show="basicMenuOpen"><i class="fas fa-caret-up clickicon"></i></span>
                  <transition>
                  <ul class="drop-menu basic-menu" v-show="basicMenuOpen">
                    <li class="basic-menu__item">
                      <a class="user-container">
                        <!-- <i class="fas fa-user-circle"></i> -->
                        <span class="user-container__avatar">{{getInitial}}</span>
                        <span>{{currentUser.name}}</span>
                      </a>
                    </li>

                    <li class="basic-menu__item"><a href="/logout" data-method="delete"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
                  </ul>
                  </transition>
                </div>
                <div class="global-header__menu-container">
                  <div class="header__toggle" @click="toggleMenu" :class="openFlg? 'is-show':''">
                    <span class="header__toggle-text"></span>
                  </div>
                </div>
              </div>
            </li>
          </ul>
        
        </div>
      </div>
    </header>
</template>
<script>

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
      openFlg: false
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
    }
  },
  mounted() {
    window.addEventListener('click', this.closeDropDown)
  },
  created: function() {
  },
  beforeDestroy() {
    window.removeEventListener('click', this.closeDropDown)
  },
  
  methods: {
    logout: function () {

    },
    dropMenu: function () {
      this.basicMenuOpen = !this.basicMenuOpen
    },
    closeDropDown(event) {
      if (!this.$el.querySelector('.drop-menu').contains(event.target) && !this.$el.querySelector('.drop-down-btn').contains(event.target)){
        this.basicMenuOpen = false
      }
    },
    toggleMenu() {
      this.openFlg = !this.openFlg
      this.$emit('toggle-sidemenu', this.openFlg)
    }
  }
}
</script>

<style lang="scss" scoped>
#header {
  position: fixed;
  z-index: 2;
  width: 100%;
  top: 0;
  background: #FFF;
  a:hover {
    opacity: 0.7;
  }
  height: 50px;
  line-height: 50px;
  box-shadow: 0px 1px 4px rgba(0,0,0,0.5);
  .inner {
    width: 100%;
    height: 100%;
    .header-logo-container {
      display: block;
      .imgBox {
        width: 160px;
        display: block;
        height: 100%;
        padding-top: 5px;
      }
    }
    
    padding: 0px 20px;
    margin:0 auto;
    display: flex;
    justify-content: space-between;
    .menulist {
      display: flex;
      height: 100%;
      .menu {
        position: relative;
        .icon-container{
          position: absolute;
          top: 50%;
          right: 0;
          transform: translateY(-50%);
          .icon-box {
            position: relative;
            .clickicon {
              position: absolute;
              top: 50%;
              left: 50%;
              transform: translate(-50%,-50%);
            }
            
          }
          .drop-down-btn {
            position: relative;
            &:hover {
              cursor: pointer;
            }
            .drop-menu {
              position: absolute;
              right: 0px;
              top: 30px;
              box-shadow: 0px 1px 4px rgba(0,0,0,0.5);
            }
            .basic-menu {
              background: #FFF;
              width: 180px;
              padding: 2px 2px;
              &__item {
                a {
                  padding: 0px 3px;
                  display: inline-block;
                  font-weight: bold;
                  text-decoration: none;
                  color: #000;
                  border-radius: 10px;
                  width: 100%;
                  
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
              }
            }
          }
          
        }
      }
    }
    .round-btn {
      display: none;
      width: 30px;
      height: 30px;
      background: #C0C0C0;
      border-radius: 50%;
      @media screen and (min-width:768px) {
        display: block;
      }
    }
    .global-header__menu-container {
      position: relative;
      display: flex;
      align-items: center;
      @media screen and (min-width:768px) {
        display: none;
      }
      .header__toggle {
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        align-content: center;
        width: 24px;
        height: 18px;
        margin-top: 0;
        margin-left: 0;
        cursor: pointer;
        .header__toggle-text {
          overflow: hidden;
          font-size: 0;
          text-indent: -100%;
          position: relative;
          display: block;
          width: 24px;
          height: 2px;
          background-color: #000;
          transition-duration: .3s;
        }
        &:before,
        &:after {
          content: '';
          position: relative;
          display: block;
          width: 24px;
          height: 2px;
          background-color: #000;
          transition-duration: .3s;
        }
        &.is-show {
          &:before {
            top: 8px;
            transform: rotate(-45deg);
            background-color: #000;
          }
           &:after {
            bottom: 8px;
            transform: rotate(45deg);
            background-color: #000;
          }
          .header__toggle-text {
            opacity: 0;
          }
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
</style>