class WebException < Exception
	attr_accessor :code
	attr_accessor :format
	
	def initialize(message, code)
		super(message)
		self.code = code
	end
end