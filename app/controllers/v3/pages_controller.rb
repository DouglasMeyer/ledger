module V3
  class PagesController < BaseController
    before_action :admin_only, only: :admin

    def admin
      render html: '<div class="admin"></div>'.html_safe, layout: 'v3_react'
    end

    def angular
      render html: '<div ng-view></div>'.html_safe, layout: true
    end

    def react
      render html: '<div class="app"></div>'.html_safe, layout: 'v3_react'
    end
  end
end
