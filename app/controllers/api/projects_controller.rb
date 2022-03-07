class Api::ProjectsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # GET /projects
  def index
    # @projects = Project.where(owner_id: current_user.id, workspace_id:nil).order('id ASC')
    # @projects = current_user.projects.order('id DESC')
    @projects = Project.joins(:users).where(users: {id: current_user.id} ).select("projects.*, project_members.role")

    @projects.each_with_index do |project, i|
      boards = project.boards.joins(:users).where(users: {id: current_user.id} ).select("boards.*, board_members.role")
      @projects[i].boards = boards
    end

  end

  # POST /project
  def create
    @project = Project.new(project_params)
    if @project.save
      render :show, status: :created
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  def show
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update_attributes(project_params)
      render :show, status: :created
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @project = Project.find(params[:id])
    if @project.destroy
      head :no_content
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  def update_members
    @project = Project.find(params[:id])
    if @project.update(project_params_update) && @project.ensure_no_member
      success = true
      if project_params_update[:user_ids]
        @project.project_members.each do |member|
          index = project_params_update[:user_ids].index(member.user_id)
          member.role = (project_member_params[:roles][index])

          if member.save
            sendmail_user_id = project_member_params[:sendmail_user_ids].find { |n| n == member.user_id}
            @sendmail_user = sendmail_user_id && User.find(sendmail_user_id)
            current_user.send_announcement_email_of_join_the_project_mail(@sendmail_user, @project) if @sendmail_user
          else
            success = false
          end
        end
      end
      if success
        @members = @project.build_member
        render :show, status: :created
      else
        render json: @project.errors, status: :unprocessable_entity
      end
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.fetch(:project, {}).permit(:name, :description).merge(user_ids: [current_user.id])
  end

  def project_params_update
    params.require(:project).permit(user_ids: [] )
  end

  def project_member_params
    params.require(:project_member).permit(roles: [], sendmail_user_ids: [])
  end
end