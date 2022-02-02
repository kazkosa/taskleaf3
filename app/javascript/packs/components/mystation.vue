<template>
  <div class="page-container">
    <h1>My Station</h1>

    <section class="subsection">
      <h2>Resent Tasks</h2>
    </section>

    <section class="subsection">
      <h2>Projects</h2>
      <ul class="project-list">
        <li v-for="(item,index) in projects" v-bind:key="index" class="project-list__item">
          <router-link :to="{ name: 'project', params: { id: item.id }}" class="project-list__item__link">
            <div class="name">
              <span class="icon_char">{{item.name[0]}}</span>
              <span>{{item.name}}</span>
            </div>
          </router-link>
          <div class="sw-cnt" @click.stop="toggleCntList(item.id)">
            <i class="fas fa-ellipsis-v"></i>
          </div>
          <transition name="fade">
            <ul v-if="item.id === selectedCntListId" class="cnt-list">
              <li class="cnt-list__item" @click="openFormProjectEdit(item.id)">Edit</li>
              <li class="cnt-list__item" @click="openConfirmProjectDelete(item.id)">Delete</li>
            </ul>
          </transition>
        </li>
      </ul>
      <a class="addbtn" @click="openFormProjectNew">
        <span class="icon"><i class="fas fa-plus"></i></span>
        <span class="txt2">Create New Project</span>
      </a>
    </section>

    <section class="subsection">
      <h2>Profile</h2>
    </section>

  </div>
</template>
<script>
export default {
  props: {
    currentUser: {
      type: Object,
      require: false
    },
    selectedSpaceId: {
      type: Number,
      require: false
    },
    projects: {
      type: Array,
      require: false
    }

  },
  data: function () {
    return {
      selectedCntListId: 0,
    }
  },
  mounted() {
    window.addEventListener('click', this.closeCntList);
  },
  beforeDestroy() {
    window.removeEventListener('click', this.closeCntList);
  },

  
  methods: {

    openFormProjectNew: function() {
      this.$emit('open-form-project-edit')
    },
    
    openFormProjectEdit: function (project_id) {
      // this.cntListOpen = !this.cntListOpen
      console.log(project_id)
      this.$emit('open-form-project-edit', project_id)

    },
    toggleCntList: function (project_id) {
      // this.cntListOpen = !this.cntListOpen
      console.log(project_id)
      this.selectedCntListId = project_id
    },
    closeCntList: function(event) {
      if (this.selectedCntListId && !this.$el.querySelector('.cnt-list').contains(event.target) && !this.$el.querySelector('.sw-cnt').contains(event.target)) {
        this.selectedCntListId = 0
      }

    },
    openConfirmProjectDelete: function (project_id) {
      this.$emit('open-confirm-project-delete', project_id)

    },
  }


}
</script>

<style lang="scss">
  
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
  .addbtn {
    padding: 0 0 0 10px;
    display: block;
    text-align: right;
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

  .project-list {
    display: flex;
    flex-wrap: wrap;
    justify-content: flex-start;
    flex-flow: column;
    @media screen and (min-width:768px) {
      flex-flow: row;
      flex-wrap: wrap;
    }
    &__item {
      
      width: 80%;
      max-width: 220px;
      margin:0 5px 30px;
      position: relative;
      background-color: #fff;
      min-height:80px;
      border-radius: 5px;
      box-shadow: 0px 1px 1px 0px rgba(0, 0, 0, .2);
      @media screen and (min-width:768px) {
        width: 30%;
        margin:0 10px 30px;
      }
      
      &__link {
        // margin: 0 auto;
        width: 100%;
        
        display: block;
        height: 100%;
        // min-height:80px;
        // border-radius: 5px;
        // background-color: #fff;
        
        .name {
          padding: 10px;
          color: #000;
        }
      }
      .sw-cnt {
        position: absolute;
        top: 10px;
        right: 10px;
        width: 20px;
        height: 20px;
        text-align: center;
        cursor: pointer;
        vertical-align: middle;
        display: flex;
        align-items: center;
        justify-content: center;
        &:hover {
          color: #551A8B
        }
      }
      .cnt-list {
        display: block;
        position: absolute;
        top: 10px;
        right: 30px;
        padding: 10px;
        box-shadow: 0px 1px 1px 1px rgba(0, 0, 0, .2);
        border-radius: 4px;
        background: #fff;
        li {
          padding: 10px;
          border-top: 1px solid #ccc;
          cursor: pointer;
          &:first-child {
            border-top: none;
          }
          &:hover {
            opacity: 0.7;
          }
          
        }

      }
    }
  }
  .fade-enter-active, .fade-leave-active {
    transition: opacity .3s;
  }
  .fade-enter, .fade-leave-to {
    opacity: 0;
  }

</style>