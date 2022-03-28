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
    if @workspace_member.destroy
      head :no_content
    else
      render json: @member.errors, status: :unprocessable_entity
    end
  end

  private

  def member_params
    params.fetch(:workspace_member, {}).permit(:role)
  end

end