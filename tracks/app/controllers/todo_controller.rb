class TodoController < ApplicationController
  
  helper :todo
  model :context, :project
  
	before_filter :login_required
	caches_action :list, :completed
  layout "standard"
    
	# Main method for listing tasks
	# Set page title, and fill variables with contexts and done and not-done tasks
	#
	def list
		@page_title = "List tasks"
		@places = Context.find_all
		@projects = Project.find_all
		@done = Todo.find_all( "done=1", "completed DESC", 5 )
		@count = Todo.count( "done=0" )
	end


	# List the completed tasks, sorted by completion date
	#
  def completed
    @page_title = "Completed tasks"
    @done = Todo.find_all( "done=1", "completed DESC" )
  end
  
	
	# Called by a form button
	# Parameters from form fields should be passed to create new item
	#
	def add_item
    @item = Todo.new
		@item.attributes = @params["new_item"]
		
		# Convert the date format entered (as set in config/settings.yml)
		# to the mysql format YYYY-MM-DD
		if @params["new_item"]["due"] != ""
		  date_fmt = app_configurations["formats"]["date"]
  		formatted_date = DateTime.strptime(@params["new_item"]["due"], "#{date_fmt}")
  		@item.due = formatted_date.strftime("%Y-%m-%d")
  	else
  	  @item.due = "0000-00-00"
		end
		
		# This doesn't seem to be working. No error, but the error 
		# message isn't printed either.
		unless @item.errors.empty?
		  error_msg = ''
        @item.errors.each_full do |message|
          error_msg << message
        end
      return error_msg
    end
    
    if @item.save
		  flash["confirmation"] = "Next action was successfully added"
			redirect_to( :action => "list" )
		else
		  flash["warning"] = "Couldn't add the action because of an error: #{error_msg}"
		  redirect_to( :action => "list" )
		end
	end
	
	
	def edit
    @item = Todo.find(@params['id'])
    @belongs = @item.project_id
    @page_title = "Edit task: #{@item.description}"
    @places = Context.find_all
    @projects = Project.find_all
  end


  def update
    @item = Todo.find(@params['item']['id'])
    @item.attributes = @params['item']
    if @item.save
      flash["confirmation"] = 'Next action was successfully updated'
      redirect_to :action => 'list'
    else
      flash["warning"] = 'Next action could not be updated'
      redirect_to :action => 'list'
    end
  end
	

	def destroy
	  item = Todo.find(@params['id'])
		if item.destroy
			flash["confirmation"] = "Next action was successfully deleted"
			redirect_to :action => "list"
		else
			flash["warning"] = "Couldn't delete next action"
			redirect_to :action => "list"
		end
	end
	
	# Toggles the 'done' status of the action
	#
	def toggle_check
	  item = Todo.find(@params['id'])
		
		item.toggle!('done')
		
		if item.save
		  flash["confirmation"] = "Next action marked as completed"
			redirect_to( :action => "list" )
		else
		  flash["warning"] = "Couldn't mark action as completed"
			redirect_to( :action => "list" )
		end	
	end
	
	
end