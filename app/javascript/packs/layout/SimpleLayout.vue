<template>
  <div>
    <Navbar
      @toggle-sidemenu="toggleSideMenu"
      :rst-global-menu-btn-flg="rstGlobalMenuBtnFlg"
      @open-form-workspace-edit="openFormWorkspaceEdit"
    ></Navbar>
    <div id="body">
      <main>
        <div class="container">
          <router-view
            ref="page"
            @update-workspace="updateWorkspace"
            @flash-on="flashOn"
            @keypress.esc="closeModal"
            @open-confirm-workspace-delete="openConfirmWorkspaceDelete"
            @open-form-workspace-edit="openFormWorkspaceEdit"
          ></router-view>
        </div>
      </main>

      <FormWorkspaceEdit
        :is-show="showFormWorkspaceEdit"
        @close-modal="closeModal"
      ></FormWorkspaceEdit>
      
      <ModalWorkspaceDelete
        :is-show="showConfirmWorkspaceDelete"
        :workspace-id="deleteWorkspaceId"
        @update-workspace="updateWorkspace"
        @close-modal="closeModal"
      ></ModalWorkspaceDelete>

      <FlashMessage
        :is-show="showFlash"
        :message="flashMessage"
        :type="flashType"
        @flash-off="flashOff"
      />

    </div>
  </div>
</template>

<script>
import Navbar from '@/components/common/NavbarSimple'
import FormWorkspaceEdit from '@/components/modal/FormWorkspaceEdit'
import ModalWorkspaceDelete from '@/components/modal/ModalWorkspaceDelete'
import FlashMessage from '@/components/flash/FlashMessage'
import { mapGetters } from 'vuex'

export default {
  name: 'simple',
  props: {
  },
  data: function () {
    return {
      projects: [],
      showFormWorkspaceEdit: false,
      showFlash: false,
      flashMessage: '',
      flashType: '',
      isOpenSideMenuSp: false,
      rstGlobalMenuBtnFlg: false,
      showConfirmWorkspaceDelete: false,
      deleteWorkspaceId: 0,
    }
  },
  components: {
    'Navbar': Navbar,
    'FormWorkspaceEdit': FormWorkspaceEdit,
    'ModalWorkspaceDelete': ModalWorkspaceDelete,
    'FlashMessage': FlashMessage
  },
  created: function() {},
  mounted: function () {},
  computed: {
     ...mapGetters({
      currentUser: 'getCurrentUser',
      workspaces: 'getWorkspaces',
      selectedWsId: 'getSelectedWsId',
    }),
  },
  methods: {
    fetchWorkspaces: async function () {
      this.$store.dispatch('fetchWorkspaces')
    },
    openFormWorkspaceEdit: function() {
      this.showFormWorkspaceEdit = true
    },
    closeModal: function() {
      this.showConfirmWorkspaceDelete = false
      this.showFormWorkspaceEdit = false
      this.deleteWorkspaceId = 0
    },
    updateWorkspace: function() {
      this.fetchWorkspaces()
    },
    openConfirmWorkspaceDelete: function(workspace_id) {
      this.showConfirmWorkspaceDelete = true
      this.deleteWorkspaceId = workspace_id
    },
    flashOn: function(msg, type) {
      this.showFlash = true
      this.flashMessage = msg
      this.flashType = type
    },
    flashOff: function() {
      this.showFlash = false
      this.flashMessage = ''
    },
    toggleSideMenu: function(val) {
      this.isOpenSideMenuSp = val
      this.rstGlobalMenuBtnFlg = false
    },
    resetGrobalMenuBtn: function() {
      this.rstGlobalMenuBtnFlg = true
    }
  },
  beforeDestroy() {},
}
</script>

<style lang="scss">
@import url('https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,400;0,500;0,700;1,300;1,400;1,500;1,700&display=swap');
* {
  font-family: 'Roboto', sans-serif;
}
p {
  text-align: center;
}
.page-container {
  width: 95%;
  margin: 10px auto;
  .page-head {
    position: relative;
    padding-bottom: 20px;
    margin-top: 10px;
    @media screen and (min-width: 768px) {
      padding-bottom: 20px;
    }
    .sw-cnt {
      position: absolute;
      top: 10px;
      right: 0;
      width: 20px;
      height: 20px;
      text-align: center;
      cursor: pointer;
      &:hover {
        opacity: 0.7;
      }
    }
    .cnt-list {
      transition: all 300ms 0s ease;
      display: block;
      position: absolute;
      top: 10px;
      right: 30px;
      padding: 10px;
      li {
        padding: 5px;
        &:hover {
          opacity: 0.7;
        }
      }
    }
  }
  
  h1 {
    font-size: 22px;
    font-weight: 500;
    margin-bottom: 20px;
    display: inline-block;
    @media screen and (min-width: 768px) {
      font-size: 28px;
    }
  }
  .page-title-edit input {
    height: 30px;
    font-size: 22px;
    border: none;
    border-radius: 4px;
    @media screen and (min-width: 768px) {
      font-size: 28px;
    }
  }
  .page-desc {
    font-size: 16px;
    text-align:left;
    white-space: pre-wrap;
    @media screen and (min-width: 768px) {
      font-size: 18px;
    }
    &-edit textarea {
      font-size: 16px;
      text-align:left;
      border: none;
      border-radius: 4px;
      height: 3rem;
      width: 100%;
      @media screen and (min-width: 768px) {
        font-size: 18px;
      }
    }
  }
  .subsection{
    h2 {
      font-size: 18px;
      margin: 10px 0px;
      @media screen and (min-width: s768px) {
        font-size: 22px;
        margin: 10px 0px 20px;
      }
    }
  }
}
#body {
  height: calc(100vh - 50px);
  margin-top: 50px;
  display: flex;
}
main {
  width: 100%;
  background-color: #f3f3f3;
  overflow: auto;
}

.modal {
  display: block;
  height: 100vh;
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  z-index: 1000;
}
.modal__bg {
    background: rgba(0,0,0,.8);
    height: 100vh;
    position: absolute;
    width: 100%;
}
.modal__content {
    background: #fff;
    left: 50%;
    padding: 10px;
    position: absolute;
    top: 50%;
    transform: translate(-50%,-50%);
    width: 90%;
    max-width: 800px;
    margin: 0 auto;
    text-align: center;
    .js-modal-close {
      position: absolute;
      top: 15px;
      right: 10px;
      cursor: pointer;
      span {
        display: block;
        width: 20px;
        height: 20px;
        position: relative;
        &::before, &::after {
          content: "";
          display: block;
          width: 100%;
          height: 2px;
          background: #333;
          transform: rotate(45deg);
          transform-origin: 0 50%;
          position: absolute;
          top: calc(14% - 5px);
          left: 14%;
        }
        &::after {
            transform: rotate(-45deg);
            transform-origin: 100% 50%;
            left: auto;
            right: 14%;
        }
      }
  }
  .modal_title {
    display: inline-block;
    font-size: 18px;
    margin: 0 auto 10px;
    line-height: 2;
    span {
        border-bottom: 1px solid #6782ae;
        padding-bottom: .3em;
    }
    
    
  }
  .modal_txt {
      margin-bottom: 20px;
  }
  .modal_message {
    margin-bottom: 20px;
    font-size: 14px;
  }
  input, textarea {
    padding: 10px 10px;
    width: 100%;
    max-width: 300px;
    border: none;
    background: #f1f1f1;
  }
  input:focus, textarea:focus {
    background: rgba(255,255,255,0.3)
  }
}

.modal-enter-active {
  transition: all 0.3s ease-out;
}
.modal-leave-active {
  transition: all 0.3s cubic-bezier(1, 0.5, 0.8, 1);
}
.modal-enter,
.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}
.js-modal {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}
.logo-top {
  width: 160px;
}
</style>
