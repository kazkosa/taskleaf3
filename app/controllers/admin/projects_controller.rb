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
  end

  def edit
    @project = Project.find(params[:id])
    @members = @project.build_member
  end

  def update
    @project = Project.find(params[:id])

    if @project.update(project_params) && @project.ensure_no_member
      success = true
      if project_params[:user_ids]
        @project.project_members.each do |member|
          
          index = project_params[:user_ids].index(member.user_id.to_s)
          member.role = (project_member_params[:roles][index]).to_i
          
          unless member.save
            success = false
          end
          
        end
      end
      if success
        flash[:success] = "Project Updated"
        redirect_to admin_project_url(@project)
      else
        render 'edit'
      end
    else
      render 'edit'
    end
  end
  def destroy
    Project.find(params[:id]).destroy
    redirect_to admin_projects_url
  end
  private
  
  def project_params
    params.require(:project).permit(:name, :description, user_ids: [] )
  end

  def project_member_params
    params.require(:project_member).permit(roles: [])
  end

  # protected

  # def redirect_to_projects
  #   redirect_to admin_projects_url, alert: 'Project not found'
  # end

end
