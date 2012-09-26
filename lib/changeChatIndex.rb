def changeChatIndex
  if params[:index] == 'up'
    $global_variable = global_variable +1
  end
   if params[:index] != 'up'
    $global_variable = global_variable -1
  end
  
  puts '#{$global_variable}'
  
  @html =''
  result = @html
  render( :json => result )

end