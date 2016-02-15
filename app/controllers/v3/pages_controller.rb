module V3
  class PagesController < BaseController
    def angular
      @do_manifest = Rails.env.production?
      render text: '<div ng-view></div>', layout: true
    end
  end
end
