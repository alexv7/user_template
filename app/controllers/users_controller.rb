class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy


  # Note that paginate takes a hash argument with key :page and value equal to
  # the page requested. User.paginate pulls the users out of the database one
  # chunk at a time (30 by default), based on the :page parameter. So, for
  # example, page 1 is users 1–30, page 2 is users 31–60, etc. If page is nil,
  # paginate simply returns the first page.
  def index
    @users = User.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    #  debugger
=begin
Check in rails s
Whenever you’re confused about something in a Rails application, it’s a good
practice to put debugger close to the code you think might be causing the
trouble. Inspecting the state of the system using byebug is a powerful method for
tracking down application errors and interactively debugging your application.
=end
  end

  # def create
  #   @user = User.new(user_params)
  #   if @user.save
  #     log_in @user
  #     flash[:success] = "Welcome to the Sample App!"
  #     redirect_to @user
  #   else
  #     render 'new'
  #   end
  # end

  # def create
  #   @user = User.new(user_params)
  #   if @user.save
  #     UserMailer.account_activation(@user).deliver_now
  #     flash[:info] = "Please check your email to activate your account."
  #     redirect_to root_url
  #   else
  #     render 'new'
  #   end
  # end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def destroy
        User.find(params[:id]).destroy
        flash[:success] = "User deleted"
        redirect_to users_url
    end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

end
