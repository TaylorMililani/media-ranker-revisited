class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def create
    auth_hash = request.env["omniauth.auth"]

    @user = User.find_by(uid: auth_hash[:uid], provider: auth_hash[:provider])

    if @user
      flash[:notice] = "Welcome back, #{@user.username}!"
    else
      @user = User.build_from_github(auth_hash)
      if @user.save
        flash[:notice] = "Welcome, #{@user.username}!"
      else
        flash[:error] = "hmm..something went wrong"
        redirect_to root_path
        return
      end

    end

    session[:user_id] = @user.id
    redirect_to root_path
  end

  def logout
    if session[:user_id].nil?
      flash[:warning] = "You were not logged in!"
      redirect_to root_path
      return
    else
      session[:user_id] = nil
      flash[:status] = :success
      flash[:notice] = "Successfully logged out"
      redirect_to root_path
      return
    end
  end
end
