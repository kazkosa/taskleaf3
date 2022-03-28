<template>
  <div>
    <component 
    :is="layout"
    :current-user-id="currentUserId"
    ></component>
  </div>
</template>

<script>

import DefaultLayout from './packs/layout/DefaultLayout.vue';
import SimpleLayout from './packs/layout/SimpleLayout.vue';

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
  computed: {
    layout: function () {
      let layout = this.$route.meta.layout ? this.$route.meta.layout + '-layout' : 'default-layout';
      return layout;
    }
  }
}

</script>