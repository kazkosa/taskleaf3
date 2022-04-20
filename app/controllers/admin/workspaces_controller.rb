class Admin::WorkspacesController < AdminController
  layout "application_admin"
  before_action :logged_in_manager

  def index
    @workspaces = Workspace.all
  end

  def new
    @workspace = Workspace.new
    @workspace.workspace_members.build
    @members = []
  end

  def create
    @workspace = Workspace.new(workspace_params)
    @workspace.workspace_members.each_with_index do |member, index|
      member.role = (workspace_member_params[:roles][index]).to_i
    end
    if @workspace.save
      flash[:success] = "Workspace Created!"
      redirect_to admin_workspace_url(@workspace)
    else
      render 'new'
    end
  end

  def show
    @workspace = Workspace.find(params[:id])
    @members = @workspace.build_member
    @project_owners = @workspace.get_project_owners
    @board_owners = @workspace.get_board_owners
  end

  def edit
    @workspace = Workspace.find(params[:id])
    @members = @workspace.build_member
    @checked_project_or_board_owner = @workspace.member_is_project_or_board_owner?(@members)
  end

  def update
    @workspace = Workspace.find(params[:id])
    target_delete_members = @workspace.diff_member(workspace_params[:user_ids])
    if workspace_params[:user_ids] && @workspace.check_member(workspace_params[:user_ids], workspace_member_params[:roles]) && @workspace.update(workspace_params) && @workspace.delete_child(target_delete_members) && @workspace.update_members(workspace_params[:user_ids].map!{|x| x.to_i}, workspace_member_params[:roles].map!{|x| x.to_i})
      flash[:success] = "Workspace Updated"
      redirect_to admin_workspace_url(@workspace)
    else
      @members = @workspace.build_member
      render 'edit'
    end
  end

  def destroy
    Workspace.find(params[:id]).destroy
    redirect_to admin_workspaces_url
  end

  private
  
  def workspace_params
    params.require(:workspace).permit(:name, :description, user_ids: [] )
  end

  def workspace_member_params
    params.require(:workspace_member).permit(roles: [])
  end
end
