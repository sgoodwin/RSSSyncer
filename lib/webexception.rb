class WebException < Exception
	attr_accessor :code
	attr_accessor :format
	
	def initialize(message, code, format='json')
		super(message || "")
		self.code = code || 424
		self.format = format
	end
end