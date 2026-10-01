class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :require_login
  before_action :require_admin
end
