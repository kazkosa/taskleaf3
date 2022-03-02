<template>
  <transition>
    <div v-if="isShow" class="flash-message" :class="getClass">
      {{message}}
    </div>
  </transition>
</template>
<script>
import axios from 'axios';
export default {
  props: {
    isShow: {
      type: Boolean,
      require: false,
      default: false
    },
    message: {
      type: String,
      require: false,
      default: ''
    },
    type: {
      type: String,
      require: false,
      default: ''
    }
  },
  watch: {
    "isShow": {
      handler: function(newVal, oldVal) {
        const _this = this
        if (newVal) {
          setTimeout(function(){
            _this.flashOff()
            
          }, 2400)
        }
      },
      deep: true,
      immediate: true
    },
  },
  computed: {
    getClass: function () {
      return this.type ? 'flash-message--' + this.type: ''
    }
  },
  data: function () {
    return {

    }
  },
  methods: {
    flashOff: function() {
      this.$emit('flash-off')
    }
  }
}
</script>

<style lang="scss" scoped>

</style>