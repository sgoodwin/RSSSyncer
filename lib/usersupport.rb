module UserSupport
	@@user_id = -1
	
	def user_id
		@@user_id
	end
	
	def user_id=(user_id)
		@@user_id = user_id
	end
end