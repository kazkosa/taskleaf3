class Api::TasksController < ApplicationController
  skip_before_action :verify_authenticity_token

  # GET /tasks
  def index
    # 後々のため、更新順で返します
    @tasks = Task.order('updated_at DESC')
  end

  # POST /tasks
  # def create
  #   @task = Task.new(task_params)

  #   if @task.save
  #     render :show, status: :created
  #   else
  #     render json: @task.errors, status: :unprocessable_entity
  #   end
  # end
  def create
    @task = Task.new(task_params)

    # @tasks = @task.state.tasks.order("tasks.sort")
    
    # @tasks.each_with_index do |task, i|
    #   if task.id
    #     task.sort = i + 1
    #     task.save
    #   end
    # end
    # @task.sort = 0
    if @task.before_create_update_tasks_sort && @task.save
      @task = Task.find(@task.id)
      @tasks = @task.state.tasks.order("tasks.sort")
      render :index, status: :created

    else
      render json: @state.errors, status: :unprocessable_entity
    end
  end

  def show
    @task = Task.find(params[:id])
  end

  # PATCH/PUT /tasks/1
  def update
    @task = Task.find(params[:id])
    if @task.update_tasks_sort(task_params[:state_id]) && @task.update(task_params)
      render :show, status: :ok
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @task = Task.find(params[:id])
    if @task.destroy
      head :no_content
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  # def task_params
  #   params.fetch(:task, {}).permit(:title,:content, :is_done )
  # end
  def task_params
    params.require(:task).permit(:title,:content, :is_done, :sort, :board_id, :state_id, :user_id, :start_date, :end_date, :scheduled_start_date, :scheduled_end_date)
  end
end