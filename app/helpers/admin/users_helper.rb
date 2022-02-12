module Admin::UsersHelper
  def registered_boards(project, user)
    # Project.joins(boards: :board_members).where(id: project.id, 'board_members.user_id': user.id)
    Project.joins(boards: :board_members).select('boards.id').where(id: project.id, 'board_members.user_id': user.id)
  end
end
