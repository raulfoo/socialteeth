require "lib/email"
include Email

class SocialTeeth < Sinatra::Base

  post "/submitUpdate" do
    
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
      ad = Ad.find(:id => params[:id])
      
      body = current_user.name + " (email " + current_user.email + ") has changed some information in their ad: <br />
      <table><tr><td></td><td>Old Info</td><td>New Info</td></tr><tr><td><tr></tr>
      Ad title: </td><td>"+ad.title+"</td><td>params[:title]</td></tr><tr><td><tr></tr>
      Ad description: </td><td>"+ad.description+"</td><td>#{params[:description]}</td></tr><tr><td><tr></tr>
      Submitter Info: </td><td>"+ad.about_submitter+"</td><td>#{params[:about_submitter]}</td></tr><tr><td><tr></tr>
      Ad url: </td><td>"+ad.url+"</td><td>#{params[:url]}</td></tr><table>"
      
      ad.update(:title => params[:title], :description => params[:description],
          :url => params[:url], :about_submitter => params[:about_submitter])
      
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
          redirect "/profile/changeInfo"
        end
      rescue Errno::ECONNREFUSED => error
        ad.destroy
        errors << "Unable to parse video URL."
        flash[:errors] = errors
        redirect "/profile/changeInfo"
      end
      
      flash[:message] = "Ad updated!"
      send_email("raulfoo@gmail.com","Add Updated", body)

      redirect "/profile/changeInfo"
    
    
    else
      flash[:errors] = errors
      redirect "/profile/changeInfo"
    end
  end

end