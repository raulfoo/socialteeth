require "bundler/setup"
require "pathological"
require "sinatra"
require "bourbon"

class SocialTeeth < Sinatra::Base
  def initialize(pinion)
    @pinion = pinion
    super
  end

  get "/" do
    erb :index
  end
end
