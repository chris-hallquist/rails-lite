require 'erb'
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params

  # setup the controller
  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = Params.new(req, route_params)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    if @already_built_response
      raise "Already rendered that"
    else
      @already_built_response = true
    end
    @res.body = content
    @res.content_type = type
  end

  # helper method to alias @already_rendered
  def already_rendered?
  end

  # set the response status code and header
  def redirect_to(url)
    if @already_built_response
      raise "Already rendered that"
    else
      @already_built_response = true
    end
    @res.status = 302
    @res.header["location"] = url
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.name.underscore
    template = File.read("views/#{controller_name}/#{template_name}.html.erb")
    render_content(ERB.new(template).result(binding), "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
    render(name) unless @already_built_response
  end
end
