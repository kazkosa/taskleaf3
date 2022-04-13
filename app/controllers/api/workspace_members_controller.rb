class Api::WorkspaceMembersController < ApplicationController
  skip_before_action :verify_authenticity_token

  # GET /members
  def index
    @workspace = Workspace.find(params[:workspace_id])
    @members = @workspace.build_member
  end

  def update
    @workspace_member = WorkspaceMember.find(params[:id])
    @workspace = @workspace_member.workspace
    @members = @workspace.build_member
    if @workspace_member.update_attributes(member_params)
      render :index, status: :created
    else
      render json: @workspace.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @workspace_member = WorkspaceMember.find(params[:id])
    # if @workspace_member.destroy
    if exec_desroy_transaction(@workspace_member)
      head :no_content
    else
      render json: @member.errors, status: :unprocessable_entity
    end
  end

  private

  def member_params
    params.fetch(:workspace_member, {}).permit(:role)
  end

  def exec_desroy_transaction (workspace_member)
    success = true
    ApplicationRecord.transaction do
      project_members = workspace_member.workspace.projects.joins(:users).where(users:{id:workspace_member.user_id}).select("project_members.*")
      
      project_members.each do |member|
        project_member = ProjectMember.find(member.id)
        
        
        board_members = Board.where({project_id: member.project_id}).joins(:users).where(users:{id: member.user_id}).select("board_members.id")
        # member.project_id
        board_members.each do |bd_member|
          board_member = BoardMember.find(bd_member.id)
          unless board_member.destroy
            success = false
          end
        end

        unless project_member.destroy
          success = false
        end
      end

      unless workspace_member.destroy
        success = false
      end
      unless success
        raise ActiveRecord::Rollback
      end
    end
    success
  end

end