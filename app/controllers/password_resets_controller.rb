class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
      @user = User.find_by(email: params[:password_reset][:email].downcase)
      if @user
        @user.create_reset_digest
        @user.send_password_reset_email
        flash[:info] = "Email sent with password reset instructions"
        redirect_to root_url
      else
        flash.now[:danger] = "Email address not found"
        render 'new'
      end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # Before filters

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # Confirms a valid user.
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # Checks expiration of reset token.
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end

end



# In Listing 10.51, compare the use of
#
# authenticated?(:reset, params[:id])
# to
#
# authenticated?(:remember, cookies[:remember_token])
# in Listing 10.26 and
#
# authenticated?(:activation, params[:id])
# in Listing 10.29. Together, these three uses complete the authentication
# methods shown in Table 10.1.





# To define the update action corresponding to the edit action in Listing 10.51,
# we need to consider four cases: an expired password reset, a successful update,
# a failed update (due to an invalid password), and a failed update (which
# initially looks “successful”) due to a blank password and confirmation. The
# first case applies to both the edit and update actions, and so logically
# belongs in a before filter (Listing 10.52). The next two cases correspond to
# the two branches in the main if statement shown in Listing 10.52. Because the
# edit form is modifying an Active Record model object (i.e., a user), we can
# rely on the shared partial from Listing 10.50 to render error messages. The
# only exception is the case where the password is empty, which is currently
# allowed by our User model (Listing 9.10) and so needs to be caught and handled
# explicitly.9 Our method in this case is to add an error directly to the @user
# object’s error messages:
