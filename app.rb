require "bundler/setup"
require "pathological"
require "sinatra/base"
require "sinatra/reloader"
require "coffee-script"
require "sinatra/content_for2"
require "rack-flash"
require "opengraph"
require "open-uri"
require "stripe"
require "lib/db"
require "lib/currency"
require "lib/authentication"
require "lib/uploader"
require "lib/labs"
require "lib/contribute"

class SocialTeeth < Sinatra::Base
  enable :sessions
  set :session_secret, "abcdefghijklmnop"
  set :views, "views"
  set :public_folder, "public"
  use Rack::Flash

  helpers Sinatra::ContentFor2

  configure :development do
    register Sinatra::Reloader
    also_reload "lib/*"
    also_reload "models/*"
  end

  configure do
    set :root, File.expand_path(File.dirname(__FILE__))
  end

  def initialize(pinion)
    @pinion = pinion
    super
  end

  before do
    @ads = Ad.filter(:is_published => true).order(:title).sort_by(&:payment_progress).reverse
    @ads << Ad[10] if production? # Exhale
  end

  get "/" do
    erb :index
  end

  get "/browse" do
    halt 404 unless current_user && current_user.admin?
    ads = Ad.order_by(:id.desc).all
    erb :browse, :locals => { :ads => ads }
  end

  get "/ads/:id" do
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    payment = Payment.select(:amount, :created_at).where(:ad_id => ad.id).order(:created_at)
    erb :details, :locals => { :ad => ad, :payment => payment }
  end

  post "/vote/:id" do
    halt 401 unless current_user
    halt 403 unless current_user.votes > 0
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    num_votes = params[:num_votes].to_i
    if num_votes && num_votes > 0 && num_votes <= current_user.votes
      DB.transaction do
        ad.votes = ad.votes + num_votes
        current_user.votes = current_user.votes - num_votes
        ad.save
        current_user.save
      end
    end
    redirect "/ads/#{ad.public_id}"
  end

  get "/about" do
    erb :about
  end

  get "/press" do
    erb :press
  end

  get "/press/launch-contest-press-release" do
    erb :launch_contest_press_release
  end

  get "/launch-contest" do
    erb :launch_contest
  end

  get "/submit" do
    ensure_signed_in
    erb :submit
  end

  post "/submit" do
    ensure_signed_in
    fields = [:title, :description, :about_submitter, :url]
    fields.each { |field| flash[field] = params[field] }
    errors = enforce_required_params(fields)
    errors << "Description is too long." unless params[:description].size < 4096
    errors << "Submitter description is too long." unless params[:about_submitter].size < 4096

    begin
      URI.parse(params[:url])
    rescue URI::InvalidURIError
      errors << "Invalid URL."
    end

    if errors.empty?
      ad = Ad.create(:title => params[:title], :description => params[:description],
          :goal => 0, :ad_type => "video", :url => params[:url], :about_submitter => params[:about_submitter],
          :user_id => current_user.id, :deadline => Time.now + 60 * 60 * 24 * 30)

      # Use thumbnail from YouTube or Vimeo
      begin
        if opengraph_video = OpenGraph.fetch(ad.url)
          open(opengraph_video.image) do |image|
            ad.thumbnail_url_base = Uploader.new.upload_ad_thumbnail(ad, image)
            ad.save
          end
        else
          ad.destroy
          errors << "Unable to parse video URL."
          flash[:errors] = errors
          redirect "/submit"
        end
      rescue Errno::ECONNREFUSED => error
        ad.destroy
        errors << "Unable to parse video URL."
        flash[:errors] = errors
        redirect "/submit"
      end

      redirect "/submit_complete"
    else
      flash[:errors] = errors
      redirect "/submit"
    end
  end
  
  
  
  get "/submit_complete" do
    erb :submit_complete
  end

  get "/terms-of-use" do
    erb :terms_of_use
  end

  get "/privacy-policy" do
    erb :privacy_policy
  end

  get "/faq" do
    erb :faq
  end
  
  get "/profile/home" do
    ensure_signed_in
    ad = current_user.my_campaigns
    other = current_user.other_campaigns
    
    if (defined?(ad)).nil?
     ad= Ad.all
     flash[:message] = "You have yet to contribute to an add, below are the available causes! <a href='#' id='closeMessage' name='showMessage'> x </a>"
    end
    erb :"profile/home", :locals => {:ad_tiles => ad, :ad => false, :other_ads => other }
  end
  
   get "/profile/home/firstlogin" do
    ensure_signed_in
    ad = current_user.my_campaigns
    other = current_user.other_campaigns
    flash[:message] = "You're in. Thanks for registering. <a href='#' id='closeMessage' name='showMessage'> x </a>"
    if (defined?(ad)).nil?
      ad= Ad.all
      flash[:additionalInfo] = "You currently have not joined any campaigns. Below is a selection of all available campaigns"
    end
   erb :"profile/home", :locals => {:ad_tiles => ad, :ad => false, :other_ads => other }
  end
  
  get "/profile/home/:id" do
    ensure_signed_in
    halt 404 unless this_ad = Ad.find(:public_id => params[:id])
    ad = current_user.my_campaigns
    other = current_user.other_campaigns
    user_contribution = Payment.where(:email => current_user.email, :ad_id => this_ad.id).sum(:amount)
    payment = Payment.select(:amount, :created_at).where(:ad_id => this_ad.id).order(:created_at)
    erb :"profile/home", :locals => { :ad => this_ad, :ad_tiles => ad, :payment => payment, :user_contribution => user_contribution, :other_ads => other }
  end
  
  get "/profile/settings" do
    ensure_signed_in
    erb :"profile/settings"
  end
  
  get "/profile/changeInfo" do
    ensure_signed_in
    ad = Ad.where(:user_id => current_user.id)
    erb :"profile/changeInfo", :locals => {:ad => ad }
  end
  
  get "/widgets/embed" do
   #ad = Ad.where(:user_id => current_user.id)
    erb :"widgets/embed"
  end
  
   get "/widgets/embed/:id" do
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    erb :"widgets/embed", :locals => { :ad => ad }
  end
  
  get "/externalWidgetSC" do
    erb :externalWidgetSC, :layout=> false
  end

  get "/externalWidgetSC/:id" do
    halt 404 unless ad = Ad.find(:public_id => params[:id])
    erb :externalWidgetSC,  :locals => { :ad => ad }, :layout=> false
  end

  def ensure_signed_in
    redirect "/signin?redirect=#{request.path_info}" if current_user.nil?
  end

  def enforce_required_params(fields)
    empty_fields = fields.select { |field| params[field].nil? || params[field].empty? }
    empty_fields.empty? ? [] : ["All fields are required."]
  end

  def in_labs?
    request.path.match(/^\/labs/) && !production?
  end

  def production?() ENV["RACK_ENV"] == "production" end
  
end
