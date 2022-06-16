<template>
  <div>
    <component 
    :is="layout"
    ></component>
  </div>
</template>

<script>

import DefaultLayout from '@/layout/DefaultLayout.vue';
import SimpleLayout from '@/layout/SimpleLayout.vue';

export default {
  components: {
    DefaultLayout,
    SimpleLayout
  },
  props: {
    currentUserId: {
      type: Number,
      require: false
    }
  },

  data: function () {
    return {
      breakPoint: 768
    }
  },
  created: function() {
    window.addEventListener('resize', this.handleResize)
    this.initialize()
  },
  computed: {
    layout: function () {
      let layout = this.$route.meta.layout ? this.$route.meta.layout + '-layout' : 'default-layout';
      return layout;
    }
  },
  methods: {
    initialize: async function() {

      const _this = this
      await Promise.all([
        this.handleResize(),
        this.fetchCurrentUser(),
        this.fetchWorkspaces()
      ])
      this.fetchProjects()
      
    },
    fetchCurrentUser: function () {
      this.$store.dispatch('fetchCurrentUser', { userId: this.currentUserId })
    },
    fetchWorkspaces: function () {
      this.$store.dispatch('fetchWorkspaces')
    },
    fetchProjects: function () {
      this.$store.dispatch('fetchProjects')
    },
    handleResize: function() {
      let windowWidth = window.innerWidth
      this.$store.commit('setIsPC', windowWidth >= this.breakPoint)
    },
    beforeDestroy() {
      window.removeEventListener('resize', this.handleResize)
    },
  }
}

</script>