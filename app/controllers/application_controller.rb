class ApplicationController < ActionController::Base
  helper_method :current_user, :current_workspace
  before_action :require_session

  rescue_from TicketWorkflow::NotAuthorized, with: :forbidden

  private

  def current_workspace
    @current_workspace ||= Workspace.find_by(id: session[:workspace_id])
  end

  def current_user
    @current_user ||= current_workspace&.users&.find_by(id: session[:user_id])
  end

  def require_session
    redirect_to root_path, alert: "Devam etmek için demo oturumu açın." unless current_user
  end

  def require_agent
    raise TicketWorkflow::NotAuthorized unless current_user&.agent?
  end

  def forbidden
    render plain: "Bu işlem için yetkiniz yok.", status: :forbidden
  end
end
