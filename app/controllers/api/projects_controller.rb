class Api::ProjectsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # GET /projects
  def index
    # @projects = Project.where(owner_id: current_user.id, workspace_id:nil).order('id ASC')
    @projects = current_user.projects.order('id DESC')
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
      render json: @book.errors, status: :unprocessable_entity
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

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.fetch(:project, {}).permit(:name, :description)#.merge(owner_id: current_user.id)
  end
end