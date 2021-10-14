<template>
  <div>
    <navbar
      :current-user="current_user"
    ></navbar>
    <div id="body">
      <sidebar
        :current-user="current_user"
      ></sidebar>
      <main>
        <p>{{ message }}</p>
        <ul>
          <li><router-link to="/">Top</router-link></li>
          <li><router-link to="/about">About</router-link></li>
          <li><router-link to="/contact">Contact</router-link></li>
        </ul>
        <div class="container">
          <router-view></router-view>
        </div>
      </main>
    </div>
  </div>
</template>

<script>
import navbar from './packs/components/navbar'
import sidebar from './packs/components/sidebar'
import axios from 'axios';

export default {

  props: {
    currentUserId: {
      type: Number,
      require: false
    }
  },
  data: function () {
    return {
      message: "Hello Vue!!",
      current_user: {
        id: null,
        email:'',
        name: ''
      }
    }
  },

  components: {
    'navbar': navbar,
    'sidebar': sidebar
  },

  mounted: function () {
    this.fetchCurrentUser();
  },
  methods: {
    fetchCurrentUser: function () {
      axios.get('/api/users/'+this.currentUserId).then((res) => {
        console.log(res)
        this.current_user.id = parseInt(res.data.user.id)
        this.current_user.email = res.data.user.email 
        this.current_user.name = res.data.user.name 
      }, (error) => {
        console.log(error);
      });

    },
  }
}
</script>

<style lang="scss" scoped>
@import url('https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,400;0,500;0,700;1,300;1,400;1,500;1,700&display=swap');
* {
  font-family: 'Roboto', sans-serif;
}
p {
  font-size: 2em;
  text-align: center;
}
#body {
  height: calc(100vh - 50px);
  margin-top: 50px;
  display: flex;
}
</style>
