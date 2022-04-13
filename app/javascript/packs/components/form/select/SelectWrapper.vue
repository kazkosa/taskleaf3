<template>
  <div class="select-wrapper">
    <div class="select-dropdown" :class="className" @click="switchDropdown">{{optionList[slectedIndex].name}}</div>
    <svg class="caret" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="M7 10l5 5 5-5z"></path><path d="M0 0h24v24H0z" fill="none"></path></svg>
    <transition>
      <ul class="select-options" v-show="isOpen">
        <li class="option"><span class="head">{{initText}}</span></li>
        <li v-for="(item,index) in optionList" v-bind:key="index" class="option">
          <span class="option__content" :class="index==slectedIndex? 'selected':''" @click="changeOption(item.id)">{{item.name}}</span>
        </li>
      </ul>
    </transition>
  </div>
</template>
<script>

export default {
  watch: {
    "initSelected": {
      handler: function(newVal, oldVal) {
        if (newVal !== oldVal) {
          this.initialize()
        }
      },
      deep: true,
      immediate: true
    },
     "optionList": {
      handler: function(newVal, oldVal) {
        if (oldVal === undefined || newVal.length !== oldVal.length) {
          this.initialize()
        }
      },
      deep: true,
      immediate: true
    },
    'reset': {
      handler: function(newVal, oldVal) {
        if (newVal) {
          this.initialize()
        }
      },
      deep: true,
      immediate: true
    }
  },
  props: {
    initText: {
      type: String,
      require: false
    },
    optionList: {
      type: Array,
      require: false,
      default: []
    },
    initSelected: {
      type: Number,
      require: false,
      default: 0
    },
    type: {
      type: String,
      require: false,
      default: ''
    },
    reset: {
      type: Boolean,
      require: false,
      default: false
    }
  },
  data: function () {
    return {
      slectedIndex: 0,
      isOpen: false
    }
  },
  mounted() {
    window.addEventListener('click', this.closeDropDown);
  },
  created: function() {
    this.initialize()
  },
  beforeDestroy() {
    window.removeEventListener('click', this.closeDropDown);
  },
  computed: {
    className: function () {
      return this.type? 'is-' + this.type: ''
    },
  },

  methods: {
    initialize: function() {
      // if (this.initSelected) {
        this.changeOption(this.initSelected)
      // }
    },
    switchDropdown: function() {
      this.isOpen = !this.isOpen
    },
    changeOption: function(id) {
      const index = this.optionList.findIndex((option) => option.id == id)

      this.slectedIndex = index
      this.isOpen = false
      if (this.optionList[index]) {
        this.$emit('change-value', this.optionList[index].id)
      }
    },
    closeDropDown(event) {
      if (!this.$el.querySelector('.select-options').contains(event.target) && !this.$el.querySelector('.select-dropdown').contains(event.target)){
        this.isOpen = false
      }
    }
  }
}
</script>
<style lang="scss" scoped>
.select-wrapper {
    position: relative;
}
.select-dropdown {
  position: relative;
  cursor: pointer;
  background-color: transparent;
  border: none;
  border-bottom: 1px solid #9e9e9e;
  outline: none;
  height: 3rem;
  line-height: 3rem;
  width: 100%;
  font-size: 16px;
  margin: 0 0 8px 0;
  padding: 0;
  display: block;
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
  z-index: 1;
  &.is-noborder {
    border-bottom: none;
    margin: 0;
    height: 2.6rem;
    line-height: 2.6rem;
  }
}
.select-options {
  background-color: #fff;
  margin: 0;
  min-width: 100px;
  overflow-y: auto;
  position: absolute;
  left: 0;
  top: 0;
  z-index: 9999;
  -webkit-transform-origin: 0 0;
  transform-origin: 0 0;
  width: 100%;
  box-shadow: 0px 1px 4px rgba(0, 0, 0, 0.5);
}
.select-wrapper .caret {
  position: absolute;
  right: 0;
  top: 0;
  bottom: 0;
  margin: auto 0;
  z-index: 0;
  fill: rgba(0,0,0,0.87);
}
.option {
  clear: both;
  color: rgba(0,0,0,0.87);
  cursor: pointer;
  min-height: 50px;
  line-height: 1.5rem;
  width: 100%;
  text-align: left;
  span {
    font-size: 16px;
    color: #26a69a;
    display: block;
    line-height: 22px;
    padding: 14px 16px;
    width: 100%;
    height: 100%;
    display: block;
  }
  .head {
    color: #888;
    cursor: auto;
  }
  .selected {
    background: #EEE;
  }
  &__content:hover {
    background: #EEE;
    opacity: 0.7;
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