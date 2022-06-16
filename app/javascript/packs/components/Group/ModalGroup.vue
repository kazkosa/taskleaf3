<template>
  <div>
    <ModalWorkspaceDelete
      :is-show="type === 'delete_ws' ? isShow: false"
      :workspace-id="targetId"
      @update-workspace="updateWorkspace"
      @close-modal="closeModal"
    ></ModalWorkspaceDelete>

    <ModalProjectDelete
      :is-show="type === 'delete_pj' ? isShow: false"
      :project-id="targetId"
      @update-project="updateProject"
      @close-modal="closeModal"
    ></ModalProjectDelete>

    <ModalBoardDelete
      :is-show="type === 'delete_bd' ? isShow: false"
      :board-id="targetId"
      @update-board="updateBoard"
      @close-modal="closeModal"
    ></ModalBoardDelete>

    <ModalStateDelete
      :is-show="type === 'delete_state' ? isShow: false"
      :state-id="targetId"
      @update-state="updateState"
      @close-modal="closeModal"
    ></ModalStateDelete>

    <ModalTaskDelete
      :is-show="type === 'delete_task' ? isShow: false"
      :task-id="targetId"
      @update-state="updateState"
      @close-modal="closeModal"
    ></ModalTaskDelete>

    <FormWorkspaceEdit
      :is-show="type === 'new_ws' ? isShow: false"
      @close-modal="closeModal"
    ></FormWorkspaceEdit>

    <FormProjectEdit
      :is-show="type === 'edit_pj' ? isShow: false"
      @close-modal="closeModal"
      :project-id="targetId"
      @update-project="updateProject"
    ></FormProjectEdit>

    <FormBoardEdit
      :is-show="type === 'new_bd' || type === 'edit_bd' ? isShow: false"
      :project-id="type === 'new_bd' ? targetId : 0"
      :board-id="type === 'edit_bd' ? targetId : 0"
      @close-modal="closeModal"
      @update-board="updateBoard"
    ></FormBoardEdit>

    <FormStateEdit
      :is-show="type === 'new_state' || type === 'edit_state' ? isShow: false"
      :board-id="type === 'new_state' ? targetId : 0"
      :state-id="type === 'edit_state' ? targetId : 0"
      @close-modal="closeModal"
      @update-state="updateState"
    ></FormStateEdit>
  </div>
</template>
<script>
import ModalWorkspaceDelete from '@/components/modal/ModalWorkspaceDelete'
import ModalProjectDelete from '@/components/modal/ModalProjectDelete'
import ModalBoardDelete from '@/components/modal/ModalBoardDelete'
import ModalStateDelete from '@/components/modal/ModalStateDelete'
import ModalTaskDelete from '@/components/modal/ModalTaskDelete'
import FormWorkspaceEdit from '@/components/modal/FormWorkspaceEdit'
import FormProjectEdit from '@/components/modal/FormProjectEdit'
import FormBoardEdit from '@/components/modal/FormBoardEdit'
import FormStateEdit from '@/components/modal/FormStateEdit'

export default {
  components: {
    ModalWorkspaceDelete,
    ModalProjectDelete,
    ModalBoardDelete,
    ModalStateDelete,
    ModalTaskDelete,
    FormWorkspaceEdit,
    FormProjectEdit,
    FormBoardEdit,
    FormStateEdit
  },
  props: {
    type: {
      type: String,
      default: '',
      require: true
    },
    isShow: {
      type: Boolean,
      default: false,
      require: true
    },
    targetId: {
      type: Number,
      default: 0,
      require: true
    }
  },
  data: function () {
    return {}
  },

  methods: {
    closeModal() {
      this.$emit('close-modal', false)
    },
    updateWorkspace() {
      this.$emit('update-workspace')
    },
    updateProject() {
      this.$emit('update-project')
    },
    updateBoard() {
      this.$emit('update-board')
    },
    updateState() {
      this.$emit('update-state')
    }
  }
}
</script>