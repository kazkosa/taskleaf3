class Admin::TasksController < AdminController
  layout "application_admin"
  before_action :logged_in_manager
  before_action :set_task, only: [:show,:destroy,:edit,:update]

  def index
    @tasks = Task.all 
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)

    if @task.save
      flash[:success] = "Task Created!"
      if (params[:task][:from_board_id])
        redirect_to admin_board_url(params[:task][:from_board_id].to_i)
      else
        redirect_to admin_task_url(@task)
      end
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @task.update(task_params)
    redirect_to admin_task_url(@task)
  end

  def show
  end

  def destroy
    @task.destroy
    redirect_to action: :index
  end

  private
  def task_params
    params.require(:task).permit(
      :board_id,
      :user_id,
      :state_id,
      :title,
      :content,
      :sort,
      :archive_flg,
      :start_date,
      :end_date,
      :scheduled_start_date,
      :scheduled_end_date
    )
  end
  def set_task
    @task = Task.find(params[:id])
  end
end
