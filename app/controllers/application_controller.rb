class ApplicationController < ActionController::Base
  protect_from_forgery

protected

  def admin
    CapellaJuris::Application.config.admin
  end

  def admin_logged_in?
    if Rails.env.development?
      true
    else
      !!session[:admin]
    end
  end
  helper_method :admin_logged_in?

  def admin_not_logged_in?
    !admin_logged_in?
  end
  helper_method :admin_not_logged_in?

  def authorize
    if admin_not_logged_in?
      render "errors/401", :status => :unauthorized
    end
  end

  def store_referer(url = nil)
    if url
      session[:referer] = url
    else
      session[:referer] = request.referer
    end
  end

  def referer
    session[:referer] || home_path
  end
  helper_method :referer

  def intro_path;      "#{home_path}#intro"          end
  def news_path;       "#{home_path}#vijesti"        end
  def history_path;    "#{about_us_path}#povijest"   end
  def conductor_path;  "#{about_us_path}#jurica"     end
  def members_path;    "#{about_us_path}#clanovi"    end
  def activities_path; "#{about_us_path}#aktivnosti" end
  def last_video_path; "#{videos_path}#last"         end
end
