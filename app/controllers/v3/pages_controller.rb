module V3
  class PagesController < BaseController
    def angular
      render text: '<div ng-view></div>', layout: true
    end
  end
end
