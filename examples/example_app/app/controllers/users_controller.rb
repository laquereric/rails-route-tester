class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :profile]
  
  def index
    @users = if params[:search].present?
               User.search(params[:search])
             else
               User.all
             end.order(:name)
  end
  
  def show
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    
    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully deleted.'
  end
  
  def profile
    # Additional profile view with more details
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
    params.require(:user).permit(:name, :email, :bio)
  end
end 