class ApplicationController < ActionController::Base
  before_action :set_flash_defaults
  
  private
  
  def set_flash_defaults
    flash.now[:notice] = flash[:notice] if flash[:notice]
    flash.now[:alert] = flash[:alert] if flash[:alert]
  end
end 