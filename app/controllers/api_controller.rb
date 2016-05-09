module API
  ImpossibleAction = Class.new(StandardError)
  InvalidQuery = Class.new(StandardError)
end

class ApiController < ApplicationController
  def bulk
    api_response = API::Response.new

    ActiveRecord::Base.transaction do
      JSON.parse(request.body.string).each do |command|
        constant = get_request_resource(command['resource'])
        if !constant.nil? && constant.respond_to?(command['action'])
          response = constant.send(command['action'], command.merge('user' => session[:auth_user]))
          response['reference'] = command['reference'] if command.has_key?('reference')
          api_response << response
        else
          raise API::ImpossibleAction.new "#{command['resource']}.#{command['action']} isn't an accepted resource/action"
        end
      end
    end

    status = api_response.any_errors? ? :multi_status : :ok
    render json: api_response, status: status
  end

  private

  def get_request_resource(resource_name)
    API.const_get(resource_name)
  rescue
    nil
  end
end
