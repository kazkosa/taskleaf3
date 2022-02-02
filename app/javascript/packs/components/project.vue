<template>
  <div class="page-container">
    <div class="page-head">
      <h1 v-if="!editNameMode" class="page-title" @click="editName" >{{project.name}}</h1>
      <h1 v-else class="page-title page-title-edit" ><input type="text" v-model="project.name"></h1>
      <div v-if="project.description">
        <p v-if="!editDescMode"  class="page-desc" @click="editDesc" >{{project.description}}</p>
        <p v-else class="page-desc page-desc-edit"><textarea v-model="project.description"></textarea></p>
      </div>
    </div>
    <section class="subsection">
      <h2>Board List</h2>
      <ul class="project-list">
        <li v-for="(item,index) in boards" v-bind:key="index" class="project-list__item">
          <router-link :to="{ name: 'board', params: { id: item.id }}" class="project-list__item__link">
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
              <li class="cnt-list__item" @click="openFormBoardEdit(project.id, item.id)">Edit</li>
              <li class="cnt-list__item" @click="openConfirmBoardDelete(item.id)">Delete</li>
            </ul>
          </transition>
        </li>
      </ul>

      <div class="cntrol-container">
        <a class="addbtn" @click="openFormBoardEdit(project.id)">
          <span class="icon"><i class="fas fa-plus"></i></span>
          <span class="txt2">Create New Board</span>
        </a>
      </div>
    </section>

    <section class="subsection">
      <h2>Project Setting</h2>
    </section>



  </div>
</template>
<script>
import axios from 'axios';
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
      boards: [],
      project: {},
      editNameMode: false,
      editDescMode: false,
      selectedCntListId: 0
    }
  },
  mounted() {
    window.addEventListener('click', this.closeEdit)
    window.addEventListener('click', this.closeCntList)
  },
  created: function() {
    this.initialize()
    
  },
  beforeDestroy() {
    window.removeEventListener('click', this.closeEdit)
    window.removeEventListener('click', this.closeCntList)
  },
  watch: {
    "projects": {
      handler: function(newVal, oldVal) {
        this.initialize()
      },
      deep: true,
      immediate: true
    },
  },
  
  methods: {
    initialize: async function() {
      const projectid = parseInt(this.$route.params.id)
      this.fetchBoards(projectid)
      // this.$emit('get-projectid-from-url', projectid)
     
    },
    openFormBoardEdit: function(projectid, boardid = 0 ) {
      this.$emit('open-form-board-edit', projectid, boardid)
    },
    fetchBoards: function(project_id) {
      // console.log(project_id)
      this.$emit('get-projectid-from-url', project_id)
      axios.get('/api/projects/' + project_id).then((res) => {
        this.boards = res.data.boards
        this.project = res.data.project
      }, (error) => {
        console.log(error);
      });
    },
    editName: function() {
      console.log('edit')
      this.editNameMode = true
    },
    
    editDesc: function() {
      console.log('edit-desc')
      this.editDescMode = true
    },
    closeEdit: function(event) {
      let editFlg = false
      if (this.editNameMode && !this.$el.querySelector('.page-title-edit').contains(event.target)) {
        console.log('edit-close')
        editFlg = true
        this.editNameMode = false
      }
      if (this.editDescMode && !this.$el.querySelector('.page-desc-edit').contains(event.target)) {
        console.log('edit-desc-close')
        editFlg = true
        this.editDescMode = false
      }
      if (editFlg) {
        this.updateData()
      }
      
    },
    updateData: function() {
      axios.put('/api/projects/' + this.project.id, { project: this.project })
      .then((res) => {
        console.log(res)
        this.$emit('update-project', this.project.id)
      }, (error) => {
        console.log(error);
      });
    },
    toggleCntList: function (board_id) {
      this.selectedCntListId = board_id
    },
    closeCntList: function(event) {
      if (this.selectedCntListId && !this.$el.querySelector('.cnt-list').contains(event.target) && !this.$el.querySelector('.sw-cnt').contains(event.target)) {
        this.selectedCntListId = 0
      }

    },
    openConfirmBoardDelete: function (board_id) {
      this.$emit('open-confirm-board-delete', board_id)

    },
  
  },
  beforeRouteUpdate (to, from, next) {
    this.fetchBoards(parseInt(to.params.id))
    next();
  }

}
</script>

<style lang="scss" scoped>
  
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
  .cntrol-container {
    text-align: right;
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
      margin:0 5px 30px;
      @media screen and (min-width: 768px) {
        // width: 30%;
        width: 220px;
        margin:0 10px 30px;
      }
      
      &__link {
        margin: 0 auto;
        width: 100%;
        max-width: 220px;
        display: block;
        min-height:80px;
        border-radius: 5px;
        background-color: #fff;
        box-shadow: 0px 1px 1px 0px rgba(0, 0, 0, .2);
        .name {
          padding: 10px;
          color: #000;
        }
      }
    }
  }
  


  

</style>