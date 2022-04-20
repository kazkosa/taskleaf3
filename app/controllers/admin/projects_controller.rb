# class Admin::ProjectsController < ApplicationController
class Admin::ProjectsController < AdminController
  layout "application_admin"
  before_action :logged_in_manager
  # rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_projects

  def index
    @projects = Project.all
  end

  def new
    @project = Project.new
    @project.project_members.build
    @members = []
  end

  def create
    @project = Project.new(project_params)
    @project.project_members.each_with_index do |member, index|
      member.role = (project_member_params[:roles][index]).to_i
    end
    if @project.save
      flash[:success] = "Project Created!"
      redirect_to admin_project_url(@project)
    else
      render 'new'
    end
  end

  def show
    @project = Project.find(params[:id])
    @members = @project.build_member
    @board_owners = @project.get_board_owners
  end

  def edit
    @project = Project.find(params[:id])
    @members = @project.build_member
    @checked_board_owner = @project.member_is_board_owner?(@members)
  end

  def update
    @project = Project.find(params[:id])
    target_delete_members = @project.diff_member(project_params[:user_ids])
    if project_params[:user_ids] && @project.check_member(project_params[:workspace_id], project_params[:user_ids], project_member_params[:roles]) && @project.update(project_params) && @project.delete_child(target_delete_members) && @project.update_members(project_params[:user_ids].map!{|x| x.to_i}, project_member_params[:roles].map!{|x| x.to_i})
      flash[:success] = "Project Updated"
      redirect_to admin_project_url(@project)
    else
      @members = @project.build_member
      render 'edit'
    end
  end

  def destroy
    Project.find(params[:id]).destroy
    redirect_to admin_projects_url
  end
  private
  
  def project_params
    params.require(:project).permit(:workspace_id, :name, :description, user_ids: [] )
  end

  def project_member_params
    params.require(:project_member).permit(roles: [])
  end

end
