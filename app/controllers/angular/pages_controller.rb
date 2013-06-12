class Angular::PagesController < ApplicationController
  layout 'angular'

  def index
    render text: '<div ng-view></div>', layout: 'angular'
  end

  def page
    render params[:page], layout: false
  end

end
