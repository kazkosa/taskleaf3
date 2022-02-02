<template>
  <div class="page-container">
    Board
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

      board: {},
    }
  },
  mounted() {
  },
  created: function() {
    this.initialize()
    
  },
  watch: {

  },
  
  methods: {
    initialize: async function() {
      const boardid = parseInt(this.$route.params.id)
      this.fetchBoard(boardid)
     
    },

    fetchBoard: function(board_id) {
      // console.log(project_id)
      axios.get('/api/boards/' + board_id).then((res) => {
        console.log(res)
        this.board = res.data.board
      }, (error) => {
        console.log(error);
      });
    }
  },
  beforeRouteUpdate (to, from, next) {
    this.fetchBoards(parseInt(to.params.id))
    next();
  }

}
</script>

<style lang="scss">
 
  

</style>