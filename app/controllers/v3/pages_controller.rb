module V3
  class PagesController < BaseController
    before_action :admin_only, only: :admin

    def admin
      render text: '<div class="app"></div>', layout: 'v3_react'
    end

    def angular
      @do_manifest = Rails.env.production?
      render text: '<div ng-view></div>', layout: true
    end
  end
end
