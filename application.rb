require 'rubygems'
require 'sinatra'
require 'activerecord'
require 'redcloth'

enable :sessions

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :dbfile => 'db/application.db'
)

class Post < ActiveRecord::Base
end

class Project < ActiveRecord::Base
end

class Message < ActiveRecord::Base
end

class Trail < ActiveRecord::Base
end

class User < ActiveRecord::Base
end

get '/' do
  @posts = Post.all.reverse
  @trails = Trail.all.reverse
  custom_render_erb :index
end

get '/about' do
  erb :about
end

get '/work' do
  @projects = Project.all
  erb :work
end

get '/contact' do
  custom_render_erb :contact
end

post '/contact' do
  if((params[:name].empty? || params[:email].empty? || params[:message].empty? || params[:spam].empty?))
    flash[:notice] = "Please fill in required fields!"
  elsif(params[:spam].upcase == "ORANGE")
    @message = Message.new(:name => params[:name],
                           :email => params[:email],
                           :message => params[:message])
    @message.url = params[:url] unless params[:url].empty?
    @message.save
    flash[:notice] = "Thanks for your message! You'll hear back from me shortly!"
  else
   flash[:notice] = "Oranges are NOT #{params[:spam]}"
  end
  redirect '/contact'
end

get '/admin' do
  if(session[:admin]==1)
    @posts = Post.all
    @projects = Project.all
    @messages = Message.find(:all, :conditions => "read isnull")
    custom_render_erb :admin
  else
    custom_render_erb :login
  end
end

post '/admin' do
  username = params[:username]
  password = params[:password]
  @user = User.find(:first, :conditions => "username = '#{username}' AND password = '#{password}'")
  if(@user)
    session[:admin] = 1
  else
    flash[:notice] = "Incorrect Username/Password Combination!"
  end
  redirect '/admin'
end

get '/logout' do
  session.clear
  flash[:notice] = "You have been logged out!"
  redirect '/'
end

get '/new_post' do
  authorize
  erb :new_post
end

post '/new_post' do
  authorize
  @post = Post.new(:title => params[:title], :body => params[:body], :posted_on => Time.now)
  @post.save
  flash[:notice] = "New post added!"
  redirect '/admin'
end

get '/delete_post/:id' do
  authorize
  id = params[:id]
  Post.find(:first, :conditions=> "id = #{id}").delete
  flash[:notice] = "Post Deleted!"
  redirect '/admin'
end

get '/edit_post/:id' do
  authorize
  id = params[:id]
  @post = Post.find(:first, :conditions=> "id = #{id}")
  erb :edit_post
end

post '/edit_post' do
  authorize
  id = params[:id]
  @post = Post.find(:first, :conditions=> "id = #{id}")
  @post.title = params[:title]
  @post.body = params[:body]
  @post.save
  flash[:notice] = "Post updated!"
  redirect '/admin'
end

get '/new_project' do
  authorize
  erb :new_project
end

post '/new_project' do
  authorize
  @project = Project.new(:title => params[:title],
                         :description => params[:description],
                         :project_type => params[:project_type],
                         :thumbnail_image => "images/portfolio/#{params[:thumbnail_image][:filename]}",
                         :full_image => "images/portfolio/#{params[:full_image][:filename]}",
                         :url => params[:url])
                         
  @thumbnail_image = File.new("public/images/portfolio/#{params[:thumbnail_image][:filename]}", 'w')
  @full_image = File.new("public/images/portfolio/#{params[:full_image][:filename]}", 'w')
  @tempfile = params[:thumbnail_image][:tempfile].open
  @tempfile.each do |f|
    @thumbnail_image.print(f)
  end
  @tempfile = params[:full_image][:tempfile].open
  @tempfile.each do |f|
    @full_image.print(f)
  end       
  @project.save
  flash[:notice] = "New project added!"
  redirect '/admin'
end

get '/delete_project/:id' do
  authorize
  id = params[:id]
  Project.find(:first, :conditions=> "id = #{id}").delete
  flash[:notice] = "Project deleted!"
  redirect '/admin'
end

get '/edit_project/:id' do
  authorize
  id = params[:id]
  @project = Project.find(:first, :conditions=> "id = #{id}")
  erb :edit_project
end

post '/edit_project' do
  authorize
  id = params[:id]
  @project = Project.find(:first, :conditions=> "id = #{id}")
  @project.title = params[:title] unless params[:title].empty?
  @project.description = params[:description] unless params[:description].empty?
  @project.project_type = params[:project_type]
  @project.url = params[:url] unless[:url].empty?
  @project.save
  flash[:notice] = "Project Updated!"
  redirect '/admin'
end

get '/messages' do
  authorize
  @messages = Message.all
  erb :messages
end

get '/new_trail' do
  authorize
  erb :new_trail
end

post '/new_trail' do
  authorize
  @trail = Trail.new(:url => params[:url], :body => params[:body])
  @trail.save
  flash[:notice] = "New trail created"
  redirect '/'
end

get '/delete_trail/:id' do
  authorize
  Trail.find(:first, :conditions => "id=#{params[:id]}").delete
  flash[:notice] = "Trail deleted!"
  redirect '/'
end


############HELPERS################
# Usage: partial :foo
helpers do
  def partial(page, options={})
    erb page, options.merge!(:layout => false)
  end
end

def flash
  session[:flash] = {} if session[:flash] && session[:flash].class != Hash
  session[:flash] ||= {}
end

def custom_render_erb(*args)
  myerb = erb(*args)
  flash.clear
  myerb
end

def authorize
  redirect '/' unless(session[:admin]==1)
end