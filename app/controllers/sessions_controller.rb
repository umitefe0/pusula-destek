class SessionsController < ApplicationController
  skip_before_action :require_session

  def new
  end

  def create
    workspace = current_workspace || DemoWorkspace.create!
    # Reset the session identifier while keeping this browser's isolated demo.
    reset_session
    session[:workspace_id] = workspace.id
    session[:user_id] = workspace.users.find_by!(role: params[:role]).id
    redirect_to tickets_path, notice: "#{params[:role] == 'agent' ? 'Görevli' : 'Müşteri'} demo oturumu açıldı."
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path
  end
end
