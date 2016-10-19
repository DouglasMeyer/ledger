module V3
  class PagesController < BaseController
    before_action :admin_only, only: :admin

    def admin
      render html: '<div class="app"></div>'.html_safe, layout: 'v3_react'
    end

    def angular
      @do_manifest = Rails.env.production?
      render html: '<div ng-view></div>'.html_safe, layout: true
    end
  end
end
