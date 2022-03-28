class Api::WorkspacesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @workspaces = Workspace.joins(:users).where(users: {id: current_user.id} ).select("workspaces.*, workspace_members.role")
    @workspaces.each_with_index do |workspace, i|
      projects = workspace.projects.joins(:users).where(users: {id: current_user.id} ).select("projects.*, project_members.role")
      @workspaces[i].projects = projects
    end

  end

  def create
    @workspace = Workspace.new(workspace_params)
    @workspace.workspace_members.each_with_index do |member, index|
      member.role = 0
    end
    if @workspace.save
      @workspace = Workspace.joins(:users).where({id: @workspace.id}).where(users: {id: current_user.id}).select("workspaces.*, workspace_members.role").first
      render :show, status: :created
    else
      render json: @workspace.errors, status: :unprocessable_entity
    end
  end

  def show
    @workspace = Workspace.joins(:users).select("workspaces.*, workspace_members.role").find_by(id: params[:id])
    @workspace.projects = @workspace.projects.joins(:users).where(users: {id: current_user.id} ).select("projects.*, project_members.role")
  end

  def update
    @workspace = Workspace.joins(:users).select("workspaces.*, workspace_members.role").find_by(id: params[:id])
    @workspace.projects = @workspace.projects.joins(:users).where(users: {id: current_user.id} ).select("projects.*, project_members.role")
    if @workspace.update_attributes(workspace_params)
      render :show, status: :created
    else
      render json: @workspace.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @workspace = Workspace.find(params[:id])
    if @workspace.destroy
      head :no_content
    else
      render json: @workspace.errors, status: :unprocessable_entity
    end
  end

  def update_members
    @workspace = Workspace.joins(:users).select("workspaces.*, workspace_members.role").find_by(id: params[:id])
    @workspace.projects = @workspace.projects.joins(:users).where(users: {id: current_user.id} ).select("projects.*, project_members.role")
    if workspace_params_update[:user_ids] && @workspace.check_member(workspace_params_update[:user_ids], workspace_member_params[:roles])  && @workspace.update(workspace_params_update)
      success = true
      @workspace.workspace_members.each do |member|
        index = workspace_params_update[:user_ids].index(member.user_id)
        member.role = (workspace_member_params[:roles][index])

        if member.save
          sendmail_user_id = workspace_member_params[:sendmail_user_ids].find { |n| n == member.user_id}
          @sendmail_user = sendmail_user_id && User.find(sendmail_user_id)
          current_user.send_announcement_email_of_join_the_workspace_mail(@sendmail_user, @workspace) if @sendmail_user
        else
          success = false
        end
      end
      if success
        @members = @workspace.build_member
        render :show, status: :created
      else
        render json: @workspace.errors, status: :unprocessable_entity
      end
    else
      render json: @workspace.errors, status: :unprocessable_entity
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def workspace_params
    params.fetch(:workspace, {}).permit(:name).merge(user_ids: [current_user.id])
  end

  def workspace_params_update
    params.require(:workspace).permit(user_ids: [] )
  end

  def workspace_member_params
    params.require(:workspace_member).permit(roles: [], sendmail_user_ids: [])
  end
end