require "securerandom"
require "pony"

class SocialTeeth < Sinatra::Base
  get "/signup" do
    erb :signin
  end

  post "/signup" do
    flash[:name] = params[:name]
    flash[:email] = params[:email]
    errors = enforce_required_params([:name, :email, :password])

    if params[:email] && params[:email].match(/[^@]+@[^@]+/)
      existing_user = User.find(:email => params[:email])
      errors << "Another user exists with that email." if existing_user
    else
      errors << "Invalid email."
    end

    if errors.empty?
      self.current_user =
          User.create(:name => params[:name], :email => params[:email], :password => params[:password],
                      :votes => 100)
      redirect params[:redirect] ? params[:redirect] : "/" #there's your problem right there...
    else
      flash[:errors] = errors
      redirect "/signin?action=signup"
    end
    redirect "/signin"
  end

  post "/profile" do
    if params[:password] == params[:password_check]
      flash[:message] = "Password changed successfully."
      current_user.password = params[:password]
      current_user.save
    else
      flash[:errors] = ["Passwords did not match."]
    end

    redirect "/profile"
  end

  post "/newPassword" do
    if params[:email] && params[:email].match(/[^@]+@[^@]+/)
      existing_user = User.find(:email => params[:email])

      if existing_user
        new_password = SecureRandom.hex(8)
        existing_user.password = new_password
        existing_user.save
        send_email(params[:email], new_password)
        flash[:message] = "A new password has been sent to your email address."
      else
        flash[:errors] = ["We have no record of that email in our database."]
      end
    else
      flash[:errors] = ["Invalid email."]
    end
    redirect "/signin?action=signin"
  end

  get "/signin" do
    erb :signin
  end

  post "/signin" do
    flash[:email] = params[:email]
    errors = enforce_required_params([:email, :password])

    requested_user = User.find(:email => params[:email])
    if requested_user && requested_user.password == params[:password]
      self.current_user = requested_user
      redirect params[:redirect] ? params[:redirect] : "/"
    else
      errors << "Invalid login." if errors.empty?
      flash[:errors] = errors
      redirect "/signin?action=signin"
    end
  end

  get "/signout" do
    session.clear
    redirect "/"
  end

  def current_user()
    @current_user ||= User.find(:email => session[:email])
  end

  def current_user=(user)
    return if session[:email] == user.email
    @current_user = nil
    session.clear
    session[:email] = user.email if user
  end

 def send_email(to, password)
   Pony.mail(
     :to => to,
     :from => "Social Teeth Support <contact@socialteeth.org>",
     :via => :smtp,
     :via_options => {
       :address => "smtp.gmail.com",
       :port => "587",
       :enable_starttls_auto => true,
       :user_name => "contact@socialteeth.org",
       :password => EMAIL_PASSWORD,
       :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
     },
     :subject => "Social Teeth Temporary Password", :html_body => "Your temporary password is: "+ password +"<br /> Once you login you can change your password on your user preferences page. <br /><br /> Best,<br />Social Teeth Support")
  end
  
  
  get "/changeChatIndex" do
  
    if params[:index] == 'next'
      if($global_variable == Chat.count)
        $global_variable = 1
      else
        $global_variable = $global_variable +1
      end
    else
      if($global_variable == 1)
        $global_variable = Chat.count
      else
      $global_variable = $global_variable -1
      end
    end
  
   
    
    if Chat[$global_variable][:orientation]=="Right"
      orientation = '675px'
      orientationMessage = 'float:right'
      
    else
      orientation='0px'
      orientationMessage ='float:left'
    end
    
  
 
    @html =''
    @html =  @html+ '<div id = "speaker" style="margin-left:'+orientation+'">'
    @html =  @html+ '<img id="chatAd" src="images/bannerChatter/'+ Chat[$global_variable][:image]+'" alt ="NA"/>'
    @html =  @html+ '<div id="subtitles">'
    @html =  @html+  Chat[$global_variable][:name]+' <br />'
    @html =  @html+ '<i>'+Chat[$global_variable][:occupation]+'<br /></i>'
    @html =  @html+  Chat[$global_variable][:location] +'<br />'
    @html =  @html+  '</div></div>'
    @html =  @html+ '<div id="message" style="'+orientationMessage+'" onclick="showVid()" onmouseover="Bite()" onmouseout="Normal()">'
    @html =  @html+  '<a href="#" id="messageLink" style="'+orientationMessage+'"> "'+Chat[$global_variable][:message]+ '" </a><br />'
    @html =  @html+  '</div>'
   
   
   result = @html
   #render( :json => result )
  end
  
   post "/createAd" do
   
   if params[:submitter] == 'Submit Changes'
    #puts params[:orientation]
    #Chat.create(:name => params[:name], :occupation => params[:occupation], :location => params[:location],
            #          :message => params[:message], :image=> params['image'][:filename], :ad => params[:ad],:orientation => params[:orientation])
   errors = enforce_required_params([:name, :occupation, :location,:message,:image,:orientation])
   
   if errors.empty?
     flash[:success] = "Submission Succesful! It will be added to our posting database after a quick, Sarah Palinesque vetting process."
   
  
    File.open('public/images/bannerChatter/' + params['image'][:filename], "w") do |f|
      f.write(params['image'][:tempfile].read)
      
    end
   else 
   
    flash[:errors] = errors
   end
   
    #name = params[:image]
   
    #puts name
   # File.open(File.join(Dir.pwd,"public/uploads", name), "wb") do |f| 
      #f.write(params[:file][:tempfile].read)
      
   # end
   
   else
   
    if params[:orientation]=="Right"
      orientation = '675px'
      orientationMessage = 'float:right'
      
    else
      orientation='0px'
      orientationMessage ='float:left'
    end
    
   
    if params[:image]
      File.open('public/images/bannerChatter/' + params['image'][:filename], "w") do |f|
        f.write(params['image'][:tempfile].read)
      end
    end
    
    
    @preview = '<h3> Preview: </h3><br />'
    @preview =  @preview+ '<div id="fullBanner">'
    @preview =  @preview+ ' <div id = "speaker"  style="margin-left:'+orientation+'">'
    if params[:image]
      @preview =  @preview+ '<img id="chatAd" src="/images/bannerChatter/'+ params['image'][:filename]+ '" alt ="NA"/>'
    else
      @preview =  @preview+ '<img id="chatAd" src="" alt ="NA"/>'
    end
    
    @preview =  @preview+ '<div id="subtitles">'
    @preview =  @preview+ params[:name] + '<br />  <i>'+params[:occupation]+ '<br /></i>'+ params[:location]+' <br />'
    @preview =  @preview+ '</div></div>'
    @preview =  @preview+ '<div id="messagePreview"  style="'+orientationMessage+'" >'
    @preview =  @preview+ '<a href="#" id="messageLink"  style="'+orientationMessage+'" >"'+params[:message]+'"</a><br />'
    @preview =  @preview + '</div></div>'
    
    flash[:preview] =  @preview
    
    
    
   # File.open('public/images/bannerChatter/' + params['image'][:filename], "w") do |f|
    #  f.write(params['image'][:tempfile].read)
  end
  
    flash[:name] = params[:name]
    flash[:occupation] = params[:occupation]
    flash[:location] = params[:location]
    flash[:message] = params[:message]

    
    
    redirect "/createBanner"
   end
  
end
