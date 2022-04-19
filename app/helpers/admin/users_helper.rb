module Admin::UsersHelper
  def registered_boards(project, user)
    Project.joins(boards: :board_members).select('boards.id, boards.name').where(id: project.id, 'board_members.user_id': user.id)
  end
  def registered_states(board)
    State.where(board_id: board.id).order("states.sort")
  end
  def registered_tasks(board, state, user)
    Task.where(board_id: board.id, state_id: state.id, user_id: user.id).order("tasks.sort")
  end
end
