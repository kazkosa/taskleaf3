<template>
  <div class="form-checkbox">
   <label>
      <input :checked="checked"  @input="$emit('change', $event.target.checked)" class="filled-in" type="checkbox" :name="name" >
      <span>{{text}}</span>
  </label>
  </div>
</template>
<script>

export default {
  model: {
    prop: 'checked',
    event: 'change'
  },
  props: {
    text: {
      type: String,
      require: false,
      default: ''
    },
    name: {
      type: String,
      require: false,
      default: ''
    },
    checked: {
      type: Boolean,
      require: false,
      default: false
    }
  },
  data: function () {
    return {

    }
  },
  mounted() {
  },
  methods: {
  }
}
</script>
<style lang="scss" scoped>
  label {
    font-size: 1.6rem;
    color: #000;
  }
  [type="checkbox"]:not(:checked), [type="checkbox"]:checked {
    position: absolute;
    opacity: 0;
    pointer-events: none;
  }
  [type="checkbox"], [type="radio"] {
    box-sizing: border-box;
    padding: 0;
  }
  [type="checkbox"]+span:not(.lever):before, [type="checkbox"]:not(.filled-in)+span:not(.lever):after {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 18px;
    height: 18px;
    z-index: 0;
    border: 2px solid #5a5a5a;
    border-radius: 1px;
    margin-top: 3px;
    transition: .1s;
  }
  [type="checkbox"]+span:not(.lever) {
    position: relative;
    padding-left: 35px;
    cursor: pointer;
    display: inline-block;
    height: 25px;
    line-height: 25px;
    font-size: 1rem;
    -webkit-user-select: none;
    -moz-user-select: none;
    -ms-user-select: none;
    user-select: none;
  }
  [type="checkbox"]:checked+span:not(.lever):before {
    top: -4px;
    left: -5px;
    width: 12px;
    height: 22px;
    border-top: 2px solid transparent;
    border-left: 2px solid transparent;
    border-right: 2px solid #00bcd4;
    border-bottom: 2px solid #00bcd4;
    transform: rotate(40deg);
    -webkit-backface-visibility: hidden;
    backface-visibility: hidden;
    transform-origin: 100% 100%;
  }

  .filled-in[type="checkbox"]+span:not(.lever):after {
    border-radius: 2px;
  }

  .filled-in[type="checkbox"]+span:not(.lever):before,
  .filled-in[type="checkbox"]+span:not(.lever):after {
    content: '';
    left: 0;
    position: absolute;
    transition: border .15s, background-color .15s, width .10s .1s, height .20s .1s, top .10s .1s, left .10s .1s;
    z-index: 1;
  }

  .filled-in[type="checkbox"]:checked+span:not(.lever):after {
    top: 0;
    width: 20px;
    height: 20px;
    border: 2px solid #00bcd4;
    background-color: #00bcd4;
    z-index: 0;
  }

  .filled-in[type="checkbox"]:checked+span:not(.lever):before {
    top: 0;
    left: 0px;
    width: 8px;
    height: 13px;
    border-top: 2px solid transparent;
    border-left: 2px solid transparent;
    border-right: 2px solid #fff;
    border-bottom: 2px solid #fff;
    transform: rotateZ(37deg);
    transform-origin: 100% 100%;
  }

</style>