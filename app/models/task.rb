class Task < ApplicationRecord
  validates :title, presence: true
  belongs_to :board
  belongs_to :state, optional: true
  belongs_to :user, optional: true

  def before_create_update_tasks_sort
    result = true
    @tasks = self.state.tasks.order("tasks.sort")
    @tasks.each_with_index do |task, i|
      if task.id
        task.sort = i + 1
        unless task.save
          result = false
        end
      end
    end
    self.sort = 0
  end
  def update_tasks_sort(state_id)
    result = true
    if state_id != self.state_id
      self.sort = 0
      state = State.find(state_id)
      tasks = state.board.tasks.where({state_id: state.id}).order("tasks.sort")
      tasks.each_with_index do |task, i|
        task.sort = i + 1
        unless task.save
          result = false
        end
      end
    end
    return result
  end
end
