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
    if exec_desroy_transaction
      head :no_content
    else
      render json: @member.errors, status: :unprocessable_entity
    end
  end

  def show
    @project_member = ProjectMember.find(params[:id])
    if @project_member
      render :show
    else
      render json: { errors: { title: 'レコードが見つかりません', detail: 'IDと一致するレコードが見つかりません' }, status: :not_found }
    end
  end

  private

  def member_params
    params.fetch(:project_member, {}).permit(:role)
  end

  def exec_desroy_transaction
    success = true
    ApplicationRecord.transaction do
      @project_member = ProjectMember.find(params[:id])
      board_members = @project_member.project.boards.joins(:users).where(users:{id:@project_member.user_id}).select("board_members.id")
      board_members.each do |member|
        board_member = BoardMember.find(member.id)
        unless board_member.destroy
          success = false
        end
      end
      unless @project_member.destroy
        success = false
      end
      unless success
        raise ActiveRecord::Rollback
      end
    end
    success
  end

end