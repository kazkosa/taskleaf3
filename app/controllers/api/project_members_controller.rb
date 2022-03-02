class Api::ProjectMembersController < ApplicationController
  skip_before_action :verify_authenticity_token

  # GET /members
  def index
    @project = Project.find(params[:project_id])
    @members = @project.build_member
  end

  def update
    @project_member = ProjectMember.find(params[:id])
    @project = @project_member.project
    @members = @project.build_member
    if @project_member.update_attributes(member_params)
      render :index, status: :created
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @project_member = ProjectMember.find(params[:id])
    if @project_member.destroy
      head :no_content
    else
      render json: @member.errors, status: :unprocessable_entity
    end
  end

  private

  def member_params
    params.fetch(:project_member, {}).permit(:role)
  end

end